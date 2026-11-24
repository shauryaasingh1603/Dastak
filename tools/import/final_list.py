#!/usr/bin/env python3
"""Turns the final visit list (Final_voters_list_to_be_visited.xlsx, booth
numbers = 2027 draft-roll parts 1-431) into rows for the database.

    python3 -I tools/import/final_list.py FINAL.xlsx [--out DIR]

Writes into --out (default tools/import/out/, ignored by git):
    final_booths.json   431 booths with their polling stations
    final_people.jsonl  one person per line, for import_final_stage
    final_report.md     counts only
The people are then matched to the records already in the database there
(see the final-list migration), so visits and forms stay attached.
Nothing is sent anywhere; counts only are printed.
"""
import argparse
import collections
import json
import os
import sys

import openpyxl

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_visit_list import GENDER, RELATION, clean_epic, clean_house, number, read, text  # noqa: E402

ASDD = 'ASDD Visit List'
POSS = 'Possibly Deleted'
SUMMARY = 'Booth Summary'
CONFIDENCE = {'High': 'HIGH', 'Medium': 'MEDIUM', 'Low': 'LOW'}
# Spec order: possibly deleted (high) first, then shifted, untraceable, the rest.
PRIORITY = {'POSS_HIGH': 1, 'SHIFTED': 2, 'UNTRACEABLE': 3, 'POSS_MEDIUM': 4, 'POSS_LOW': 4}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('workbook')
    ap.add_argument('--out', default=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
    args = ap.parse_args()

    wb = openpyxl.load_workbook(args.workbook, read_only=True, data_only=True)
    summary, asdd, poss = read(wb, SUMMARY), read(wb, ASDD), read(wb, POSS)
    booths = {number(r.get('Part No')): text(r.get('Polling Station')) or None
              for r in summary if number(r.get('Part No'))}

    counts = collections.Counter()
    people = []

    def add(sheet, row, **p):
        if not p['name']:
            p['name'] = '(नाम दर्ज नहीं)'
            p['review'] = True
            counts['no name (placeholder, flagged for review)'] += 1
        people.append({'sheet': sheet, 'row': row, **p})

    for i, r in enumerate(asdd, start=2):
        category = 'UNTRACEABLE' if text(r.get('Reason (English)')).startswith('Untraceable') else 'SHIFTED'
        epic, _ = clean_epic(r.get('EPIC No'))
        add(ASDD, i, source='ASDD', category=category, asdd_reason=category, confidence=None,
            epic=epic, name=text(r.get('Elector Name')), relation=RELATION.get(text(r.get('Relation'))),
            relative=text(r.get('Relative Name')) or None, age=number(r.get('Age')),
            gender=GENDER.get(text(r.get('Gender'))), house=clean_house(r.get('House No (2025)')),
            part=number(r.get('Part No')), section=text(r.get('Draft Section (2027)')) or None,
            april_part=number(r.get('ASDD Part No (Apr-2026)')),
            old_part=number(r.get('Old Part No')), old_serial=number(r.get('Old Sr No')),
            closest=text(r.get('Similar entry on draft roll (check)')) or None, review=False)

    for i, r in enumerate(poss, start=2):
        conf = CONFIDENCE.get(text(r.get('Confidence')).split(' ')[0], 'MEDIUM')
        epic, _ = clean_epic(r.get('EPIC No'))
        add(POSS, i, source='POSS_DEL', category='POSS_' + conf, asdd_reason=None, confidence=conf,
            epic=epic, name=text(r.get('Elector Name')), relation=RELATION.get(text(r.get('Relation'))),
            relative=text(r.get('Relative Name')) or None, age=number(r.get('Age (2025 roll)')),
            gender=GENDER.get(text(r.get('Gender'))), house=clean_house(r.get('House No')),
            part=number(r.get('Likely New Part')), section=text(r.get('Draft Section (2027)')) or None,
            april_part=number(r.get('Likely Apr-2026 Booth')),
            old_part=number(r.get('Old Booth (2025)')), old_serial=None,
            closest=text(r.get('Closest draft-roll entry (check)')) or None, review=False)

    # One person once: the same EPIC and name again is a repeat (ASDD row
    # kept); the same EPIC with another name is a misread number (both kept,
    # the later one without the EPIC, flagged).
    seen = {}
    unique = []
    for p in people:
        first = seen.get(p['epic']) if p['epic'] else None
        if first is not None:
            if first['name'] == p['name']:
                counts[f"repeat of a person already listed ({p['sheet']}), loaded once"] += 1
                continue
            p['epic'] = None
            p['review'] = True
            counts['EPIC shared with a different person (EPIC left blank, flagged)'] += 1
        elif p['epic']:
            seen[p['epic']] = p
        unique.append(p)
    people = unique

    last = 1 << 30
    people.sort(key=lambda p: (p['part'], p['old_part'] or last, p['old_serial'] or last, p['sheet'], p['row']))
    counter = collections.Counter()
    for p in people:
        counter[p['part']] += 1
        p['code'] = f"371-{p['part']:03d}-F{counter[p['part']]:05d}"
        p['priority'] = PRIORITY[p['category']]
        del p['sheet'], p['row']

    by_category = collections.Counter(p['category'] for p in people)
    per_booth = sorted(counter[b] for b in booths)
    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, 'final_booths.json'), 'w', encoding='utf-8') as f:
        json.dump([{'part_no': b, 'polling_station_hi': n} for b, n in sorted(booths.items())], f, ensure_ascii=False)
    with open(os.path.join(args.out, 'final_people.jsonl'), 'w', encoding='utf-8') as f:
        for p in people:
            f.write(json.dumps(p, ensure_ascii=False) + '\n')
    lines = ['# Final list (dry run)', '',
             f'Rows: ASDD {len(asdd)}, possibly deleted {len(poss)}. Booths: {len(booths)}.', '',
             f'People to load: {len(people)}. Per booth: smallest {per_booth[0]}, '
             f'median {per_booth[len(per_booth) // 2]}, largest {per_booth[-1]}.', '',
             '| Category | People |', '|---|---:|', *[f'| {k} | {v} |' for k, v in by_category.most_common()], '',
             '| Note | Rows |', '|---|---:|', *[f'| {k} | {v} |' for k, v in counts.most_common()]]
    with open(os.path.join(args.out, 'final_report.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    print('\n'.join(lines))


if __name__ == '__main__':
    main()
