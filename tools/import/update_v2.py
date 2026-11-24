#!/usr/bin/env python3
"""Lines up version 2 of the visit-list workbook (re-checked against the
draft roll of 17 Nov 2026) with the people already loaded from version 1.

    python3 -I tools/import/update_v2.py V2_WORKBOOK.xlsx [--out DIR]

Needs tools/import/out/people.jsonl from the version 1 import (the codes
of everyone already loaded). Writes into --out (default tools/import/out/,
ignored by git):
    v2_report.md        what changes, in counts
    v2_updates.jsonl    changes to people already loaded, by code
    v2_new.jsonl        people new in version 2, for import_people

What it does:
- people now found on the draft roll ("Removed (on draft roll)") get the
  category ON_DRAFT_ROLL and the draft entry they matched, to check;
- possibly deleted people who stay get their new confidence and the
  closest draft-roll entry;
- everyone gets their 2027 draft part and section;
- possibly deleted people new in version 2 become new records.
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
NO_VISIT = 'ASDD No Visit'
REMOVED = 'Removed (on draft roll)'
CONFIDENCE = {'High': 'HIGH', 'Medium': 'MEDIUM', 'Low': 'LOW'}
PRIORITY = {'POSS_HIGH': 1, 'POSS_MEDIUM': 4, 'POSS_LOW': 4}


def key(name, relative, part):
    return (text(name), text(relative), part)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('workbook')
    ap.add_argument('--out', default=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
    args = ap.parse_args()

    with open(os.path.join(args.out, 'people.jsonl'), encoding='utf-8') as f:
        loaded = [json.loads(line) for line in f]
    by_epic = {}
    by_name = collections.defaultdict(list)
    for p in loaded:
        if p['epic']:
            by_epic[p['epic']] = p
        by_name[key(p['name'], p['relative'], p['part'])].append(p)
        # Possibly deleted people were placed by their 2025 booth too.
        if p['source'] == 'POSS_DEL' and p.get('old_part'):
            by_name[key(p['name'], p['relative'], ('old', p['old_part']))].append(p)

    wb = openpyxl.load_workbook(args.workbook, read_only=True, data_only=True)
    asdd, poss, no_visit, removed = (read(wb, s) for s in (ASDD, POSS, NO_VISIT, REMOVED))

    counts = collections.Counter()
    updates = {}  # code -> changes

    def find(epic_raw, name, relative, part, old_part=None):
        epic, _ = clean_epic(epic_raw)
        if epic and epic in by_epic:
            return by_epic[epic], 'EPIC'
        for k in (key(name, relative, part), key(name, relative, ('old', old_part)) if old_part else None):
            if k and len(by_name.get(k, [])) == 1:
                return by_name[k][0], 'name'
        return None, None

    def change(code, **fields):
        updates.setdefault(code, {'code': code}).update(fields)

    def draft(r):
        return {'draft_part': number(r.get('Draft Part (2027)')), 'draft_section': text(r.get('Draft Section (2027)')) or None}

    # 1. Draft part/section for everyone still listed; ASDD "check" notes.
    for sheet, rows in ((ASDD, asdd), (NO_VISIT, no_visit)):
        for r in rows:
            person, how = find(r.get('EPIC No'), r.get('Elector Name'), r.get('Relative Name'), number(r.get('Part No')))
            if not person:
                counts[f'{sheet}: not found among loaded people'] += 1
                continue
            counts[f'{sheet}: matched by {how}'] += 1
            fields = draft(r)
            check = text(r.get('Similar entry on draft roll (check)'))
            if check:
                fields.update(closest=check, set_closest=True)
                counts[f'{sheet}: draft-roll entry to check'] += 1
            change(person['code'], **fields)

    # 2. Possibly deleted: those who stay are re-graded; new ones are added.
    new_people = []
    counter = collections.Counter()
    for i, r in enumerate(poss, start=2):
        conf = CONFIDENCE.get(text(r.get('Confidence')).split(' ')[0], 'MEDIUM')
        category = 'POSS_' + conf
        closest = text(r.get('Closest draft-roll entry (check)'))
        part = number(r.get('Likely New Part'))
        earlier = text(r.get('On earlier list?')) == 'Yes'
        person = None
        if earlier:
            person, how = find(r.get('EPIC No'), r.get('Elector Name'), r.get('Relative Name'), part,
                               number(r.get('Old Booth (2025)')))
        if person and person['source'] != 'POSS_DEL':
            # Also on the ASDD list (loaded once, as ASDD): keeps its ASDD
            # category; only the draft part and the entry to check change.
            counts['possibly deleted, also on the ASDD list: category kept'] += 1
            change(person['code'], **({'closest': closest, 'set_closest': True} if closest else {}), **draft(r))
            continue
        if person:
            counts[f'possibly deleted, on earlier list: matched by {how}'] += 1
            if person['category'] != category:
                counts[f'possibly deleted re-graded {person["category"]} -> {category}'] += 1
            change(person['code'], category=category, priority=PRIORITY[category], closest=closest or None,
                   set_closest=True, confidence=conf, **draft(r))
            continue
        if earlier:
            counts['possibly deleted, on earlier list but not found (added as new)'] += 1
        epic, problem = clean_epic(r.get('EPIC No'))
        name = text(r.get('Elector Name'))
        if epic and epic in by_epic:
            if by_epic[epic]['name'] == name:
                # Already loaded (from another sheet): the same person, once.
                counts['possibly deleted, new: already loaded from another sheet (not added again)'] += 1
                change(by_epic[epic]['code'], **({'closest': closest, 'set_closest': True} if closest else {}))
                continue
            counts['possibly deleted, new: EPIC already loaded for another person (EPIC left blank)'] += 1
            epic = None
        review = not name
        counter[part] += 1
        new_people.append({
            'code': f'371-{part:03d}-D{counter[part]:05d}', 'part': part, 'house': clean_house(r.get('House No')),
            'name': name or '(नाम दर्ज नहीं)', 'priority': PRIORITY[category], 'review': review, 'epic': epic,
            'roll_ref': None, 'relation': RELATION.get(text(r.get('Relation'))),
            'relative': text(r.get('Relative Name')) or None, 'age': number(r.get('Age (2025 roll)')),
            'gender': GENDER.get(text(r.get('Gender'))), 'source': 'POSS_DEL', 'asdd_reason': None,
            'old_part': number(r.get('Old Booth (2025)')), 'old_serial': None, 'likely_part': part,
            'confidence': conf, 'category': category, 'closest': closest or None, 'on_roll': False,
            **draft(r),
        })
        if epic:
            by_epic[epic] = new_people[-1]
        counts['possibly deleted, new in version 2'] += 1

    # 3. Found on the draft roll: no visit needed, keep the entry to check.
    for r in removed:
        part_text = text(r.get('Part (ASDD Apr-2026 / 2025 booth)'))
        part = number(part_text)
        person, how = find(r.get('Old EPIC'), r.get('Name'), r.get('Relative Name'), part, part)
        if not person:
            counts['on draft roll: not found among loaded people'] += 1
            continue
        counts[f'on draft roll ({text(r.get("Was on"))}): matched by {how}'] += 1
        if person['code'] in updates and updates[person['code']].get('category', '').startswith('POSS'):
            counts['on draft roll but also still on the possibly deleted sheet'] += 1
        entry = text(r.get('Draft entry (name / relative)'))
        where = f"भाग {number(r.get('Draft Part (2027)'))}, क्रम {number(r.get('Draft Sr No'))}"
        change(person['code'], category='ON_DRAFT_ROLL', priority=4,
               closest=f'{entry} ({where}, EPIC {text(r.get("Draft EPIC"))})', set_closest=True,
               draft_part=number(r.get('Draft Part (2027)')))

    by_category = collections.Counter(u.get('category') for u in updates.values() if u.get('category'))
    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, 'v2_updates.jsonl'), 'w', encoding='utf-8') as f:
        for u in updates.values():
            f.write(json.dumps(u, ensure_ascii=False) + '\n')
    with open(os.path.join(args.out, 'v2_new.jsonl'), 'w', encoding='utf-8') as f:
        for p in new_people:
            f.write(json.dumps(p, ensure_ascii=False) + '\n')
    lines = ['# Visit list version 2: changes (dry run)', '',
             f'Rows: ASDD {len(asdd)}, possibly deleted {len(poss)}, no visit {len(no_visit)}, '
             f'on draft roll {len(removed)}.', '',
             '| What | People |', '|---|---:|', *[f'| {k} | {v} |' for k, v in sorted(counts.items())], '',
             f'People already loaded who change: {len(updates)}. New people: {len(new_people)}.', '',
             '| New category for loaded people | People |', '|---|---:|',
             *[f'| {k} | {v} |' for k, v in by_category.most_common()]]
    with open(os.path.join(args.out, 'v2_report.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    print('\n'.join(lines))


if __name__ == '__main__':
    main()
