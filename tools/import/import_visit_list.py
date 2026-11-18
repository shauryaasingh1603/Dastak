#!/usr/bin/env python3
"""Turns the campaign's visit-list workbook into rows for the Dastak database.

Person-first: the workbook's family grouping cannot be trusted, so every
listed person becomes their own record (a "family" of one). Households are
confirmed at the door by volunteers; the app suggests neighbours on the 2025
roll with the same house number.

    python3 -I tools/import/import_visit_list.py WORKBOOK.xlsx [--out DIR]
        [--priority spec|workbook] [--skip-low]

Writes, into --out (default tools/import/out/, ignored by git):
    report.md   reconciliation: rows read, loaded, set aside, per booth
    load.sql    one transaction that loads booths, families and voters
Nothing is sent anywhere. Real voter data must never be committed.
"""
import argparse
import collections
import json
import os
import re
import sys

import openpyxl

ASDD = 'ASDD Visit List'
POSS = 'Possibly Deleted'
SUMMARY = 'Booth Summary'

HINDI_DIGITS = str.maketrans('०१२३४५६७८९', '0123456789')
EPIC_NEW = re.compile(r'^[A-Z]{3}\d{7}$')
EPIC_OLD = re.compile(r'^[A-Z]{2,3}/\d+/\d+/\d+$')
RELATION = {'Father': 'F', 'Husband': 'H', 'Mother': 'M', 'Wife': 'O', 'Other': 'O'}
GENDER = {'Male': 'M', 'Female': 'F', 'Other': 'O'}

# Spec order (section 5): possibly deleted high, ASDD shifted, ASDD
# untraceable, possibly deleted medium/low. The workbook's notes put
# untraceable first instead.
PRIORITY = {
    'spec': {'POSS_HIGH': 1, 'SHIFTED': 2, 'UNTRACEABLE': 3, 'POSS_OTHER': 4},
    'workbook': {'UNTRACEABLE': 1, 'POSS_HIGH': 2, 'SHIFTED': 3, 'POSS_OTHER': 4},
}


def text(value):
    return '' if value is None else str(value).strip()


def number(value):
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def clean_house(value):
    house = re.sub(r'\s+', ' ', text(value).translate(HINDI_DIGITS)).strip()
    return '' if re.fullmatch(r'0*', house.replace(' ', '')) else house


def clean_epic(value):
    """Upper-cased, spaces removed. Returns (epic or None, problem or None)."""
    epic = re.sub(r'\s+', '', text(value).translate(HINDI_DIGITS)).upper().replace('\\', '/')
    if not epic:
        return None, 'no EPIC'
    if EPIC_NEW.match(epic) or EPIC_OLD.match(epic):
        return epic, None
    if re.fullmatch(r'[A-Z]{3}\d{7}[ऀ-ॿ]*', epic) or re.fullmatch(r'[ऀ-ॿ]*[A-Z]{3}\d{7}', epic):
        # A stray Hindi letter from scanning next to a valid EPIC.
        return re.sub(r'[ऀ-ॿ]', '', epic), 'EPIC had a stray Hindi letter (removed)'
    if len(epic) >= 6 and re.search(r'[A-Z]', epic) and re.search(r'\d', epic):
        return epic, 'EPIC in an unusual format (kept as is)'
    return None, 'EPIC unreadable'


def sql(value):
    if value is None:
        return 'null'
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, int):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def read(workbook, name):
    rows = list(workbook[name].iter_rows(values_only=True))
    header = [text(h) for h in rows[0]]
    return [dict(zip(header, r)) for r in rows[1:] if any(text(c) for c in r)]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('workbook')
    ap.add_argument('--out', default=os.path.join(os.path.dirname(__file__), 'out'))
    ap.add_argument('--priority', choices=sorted(PRIORITY), default='spec')
    ap.add_argument('--skip-low', action='store_true', help='leave out possibly-deleted voters with Low confidence')
    args = ap.parse_args()

    wb = openpyxl.load_workbook(args.workbook, read_only=True, data_only=True)
    summary = read(wb, SUMMARY)
    asdd = read(wb, ASDD)
    poss = read(wb, POSS)
    prio = PRIORITY[args.priority]

    booths = {}
    for r in summary:
        part = number(r.get('Part No'))
        if part is not None and 1 <= part <= 443:
            booths[part] = text(r.get('Polling Station')) or None

    people = []      # one dict per person to load
    set_aside = []   # (sheet, row number, reason)
    flags = collections.Counter()

    def add(sheet, rownum, *, part, source, reason_key, epic_raw, name, relation, relative, age, gender,
            house, old_part, old_serial, asdd_reason=None, confidence=None, likely_part=None):
        if part is None or part not in booths:
            set_aside.append((sheet, rownum, 'booth number missing or outside 1–443', part))
            return
        epic, problem = clean_epic(epic_raw)
        if problem:
            flags[problem] += 1
        review = []
        if not name:
            name = '(नाम दर्ज नहीं)'
            review.append('no name')
            flags['no name (placeholder used, flagged for review)'] += 1
        if epic is None and old_serial is None:
            review.append('no EPIC and no roll serial')
            flags['no EPIC and no roll serial (flagged for review)'] += 1
        if not house:
            flags['no house number'] += 1
        people.append(dict(
            sheet=sheet, row=rownum, part=part, source=source, priority=prio[reason_key], epic=epic,
            name=name, relation=RELATION.get(relation), relative=relative or None, age=age, gender=GENDER.get(gender),
            house=house or None, old_part=old_part, old_serial=old_serial, asdd_reason=asdd_reason,
            confidence=confidence, likely_part=likely_part, review=review,
        ))

    for i, r in enumerate(asdd, start=2):
        reason = text(r.get('Reason (English)'))
        key = 'UNTRACEABLE' if reason.startswith('Untraceable') else 'SHIFTED'
        add(ASDD, i, part=number(r.get('Part No')), source='ASDD', reason_key=key, epic_raw=r.get('EPIC No'),
            name=text(r.get('Elector Name')), relation=text(r.get('Relation')), relative=text(r.get('Relative Name')),
            age=number(r.get('Age')), gender=text(r.get('Gender')), house=clean_house(r.get('House No (2025)')),
            old_part=number(r.get('Old Part No')), old_serial=number(r.get('Old Sr No')),
            asdd_reason=key, likely_part=number(r.get('Part No')))

    for i, r in enumerate(poss, start=2):
        conf = text(r.get('Confidence')).split(' ')[0].upper()  # HIGH / MEDIUM / LOW
        if args.skip_low and conf == 'LOW':
            set_aside.append((POSS, i, 'Low confidence, left out (--skip-low)', number(r.get('Likely New Part'))))
            continue
        add(POSS, i, part=number(r.get('Likely New Part')), source='POSS_DEL',
            reason_key='POSS_HIGH' if conf == 'HIGH' else 'POSS_OTHER', epic_raw=r.get('EPIC No'),
            name=text(r.get('Elector Name')), relation=text(r.get('Relation')), relative=text(r.get('Relative Name')),
            age=number(r.get('Age (2025 roll)')), gender=text(r.get('Gender')), house=clean_house(r.get('House No')),
            # "Sr No (2025)" on this sheet runs to ~81,000, so it is not a
            # position within the old booth; it is not used.
            old_part=number(r.get('Old Booth (2025)')), old_serial=None,
            confidence=conf if conf in ('HIGH', 'MEDIUM', 'LOW') else None, likely_part=number(r.get('Likely New Part')))

    # An EPIC can repeat once a stray scanned letter is removed: the same
    # person on both sheets (same name: loaded once, the first row kept), or
    # two people with a misread number (different names: both loaded, the
    # later one without an EPIC and flagged for review).
    seen = {}
    unique = []
    for p in people:
        first = seen.get(p['epic']) if p['epic'] else None
        if first is not None:
            if first['name'] == p['name']:
                set_aside.append((p['sheet'], p['row'], 'same person on both sheets (loaded once)', p['part']))
                continue
            p['epic'] = None
            p['review'].append('EPIC clashes with another person')
            flags['EPIC clashes with a different person (EPIC left blank, flagged)'] += 1
        elif p['epic']:
            seen[p['epic']] = p
        unique.append(p)
    people = unique

    # Codes in 2025 roll order within each booth: 371-PPP-NNNNN.
    last = 1 << 30
    people.sort(key=lambda p: (p['part'], p['old_part'] or last, p['old_serial'] or last, p['sheet'], p['row']))
    counter = collections.Counter()
    for p in people:
        counter[p['part']] += 1
        p['code'] = f"371-{p['part']:03d}-{counter[p['part']]:05d}"
        p['roll_ref'] = f"P{p['old_part']:03d}-S{p['old_serial']:04d}" if p['old_part'] and p['old_serial'] else None

    # roll_ref must be unique too; drop it (not the person) on a clash.
    refs = collections.Counter(p['roll_ref'] for p in people if p['roll_ref'])
    for p in people:
        if p['roll_ref'] and refs[p['roll_ref']] > 1:
            p['roll_ref'] = None
            flags['roll reference shared by two rows (left blank)'] += 1

    os.makedirs(args.out, exist_ok=True)
    write_sql(os.path.join(args.out, 'load.sql'), booths, people)
    write_json(args.out, booths, people)
    write_report(os.path.join(args.out, 'report.md'), args, booths, asdd, poss, people, set_aside, flags)
    print(f"read {len(asdd)} + {len(poss)} rows; loadable {len(people)}; set aside {len(set_aside)}")
    print(f"wrote {os.path.join(args.out, 'report.md')} and load.sql")


def write_sql(path, booths, people):
    with open(path, 'w', encoding='utf-8') as f:
        f.write('-- Generated by tools/import/import_visit_list.py. Contains voter data: never commit.\n')
        f.write('begin;\n')
        f.write('-- Remove mock and test data (and anything recorded against it).\n')
        f.write('truncate public.form_events, public.forms, public.visit_voters, public.visits, '
                'public.voters, public.families;\n')
        f.write('insert into public.booths (part_no, name_hi, polling_station_hi) values\n')
        f.write(',\n'.join(f"  ({part}, {sql('बूथ ' + str(part))}, {sql(name)})" for part, name in sorted(booths.items())))
        f.write('\non conflict (part_no) do update set name_hi = excluded.name_hi, '
                'polling_station_hi = excluded.polling_station_hi;\n')
        for start in range(0, len(people), 1000):
            chunk = people[start:start + 1000]
            f.write('with fam as (\n  insert into public.families (code, part_no, house_no, head_name_hi, priority, needs_review) values\n')
            f.write(',\n'.join(
                f"    ({sql(p['code'])}, {p['part']}, {sql(p['house'])}, {sql(p['name'])}, {p['priority']}, {sql(bool(p['review']))})"
                for p in chunk))
            f.write('\n  returning id, code\n)\n')
            f.write('insert into public.voters (family_id, epic, roll_ref, name_hi, relation_type, relative_name_hi, age, '
                    'gender, source_list, asdd_reason, old_part_no, old_serial, likely_new_part, match_confidence)\n')
            f.write('select fam.id, v.epic, v.roll_ref, v.name_hi, v.relation_type, v.relative_name_hi, v.age, v.gender, '
                    'v.source_list, v.asdd_reason, v.old_part_no, v.old_serial, v.likely_new_part, v.match_confidence\n')
            f.write('from (values\n')
            f.write(',\n'.join(
                '  (' + ', '.join([
                    sql(p['code']), sql(p['epic']), sql(p['roll_ref']), sql(p['name']), sql(p['relation']),
                    sql(p['relative']), sql(p['age']) + '::int', sql(p['gender']), sql(p['source']),
                    sql(p['asdd_reason']), sql(p['old_part']) + '::int', sql(p['old_serial']) + '::int',
                    sql(p['likely_part']) + '::int', sql(p['confidence'])]) + ')'
                for p in chunk))
            f.write('\n) as v(code, epic, roll_ref, name_hi, relation_type, relative_name_hi, age, gender, source_list, '
                    'asdd_reason, old_part_no, old_serial, likely_new_part, match_confidence)\n')
            f.write('join fam on fam.code = v.code;\n')
        f.write('commit;\n')


def write_json(out, booths, people):
    """The same rows as JSON, for the import_booths / import_people functions."""
    with open(os.path.join(out, 'booths.json'), 'w', encoding='utf-8') as f:
        json.dump([{'part_no': p, 'polling_station_hi': n} for p, n in sorted(booths.items())], f, ensure_ascii=False)
    keys = ['code', 'part', 'house', 'name', 'priority', 'epic', 'roll_ref', 'relation', 'relative', 'age',
            'gender', 'source', 'asdd_reason', 'old_part', 'old_serial', 'likely_part', 'confidence']
    with open(os.path.join(out, 'people.jsonl'), 'w', encoding='utf-8') as f:
        for p in people:
            row = {k: p[k] for k in keys}
            row['review'] = bool(p['review'])
            f.write(json.dumps(row, ensure_ascii=False) + '\n')


def write_report(path, args, booths, asdd, poss, people, set_aside, flags):
    by_part = collections.Counter(p['part'] for p in people)
    by_source = collections.Counter(p['source'] for p in people)
    by_prio = collections.Counter(p['priority'] for p in people)
    sheet_rows = collections.Counter()
    for r in asdd:
        sheet_rows[number(r.get('Part No'))] += 1
    for r in poss:
        sheet_rows[number(r.get('Likely New Part'))] += 1
    aside_by_part = collections.Counter(a[3] for a in set_aside)
    # Every sheet row is either loaded or set aside with a reason.
    mismatched = [part for part in booths if by_part[part] + aside_by_part[part] != sheet_rows[part]]
    counts = sorted(by_part[p] for p in booths)
    lines = [
        '# Visit list import: reconciliation (dry run)', '',
        f'Priority order: **{args.priority}**. Low-confidence possibly deleted: '
        f"**{'left out' if args.skip_low else 'included, last priority'}**.", '',
        '| | Rows |', '|---|---:|',
        f'| ASDD Visit List read | {len(asdd)} |',
        f'| Possibly Deleted read | {len(poss)} |',
        f'| **People to load** | **{len(people)}** |',
        f"| of which ASDD | {by_source['ASDD']} |",
        f"| of which possibly deleted | {by_source['POSS_DEL']} |",
        f'| Set aside (not loaded) | {len(set_aside)} |', '',
        '## Priority mix', '', '| Priority | People |', '|---:|---:|',
        *[f'| {k} | {by_prio[k]} |' for k in sorted(by_prio)], '',
        '## Loaded, but worth knowing', '', '| Note | Rows |', '|---|---:|',
        *[f'| {k} | {v} |' for k, v in flags.most_common()], '',
        '## Set aside', '', '| Reason | Rows |', '|---|---:|',
        *[f'| {k} | {v} |' for k, v in collections.Counter(a[2] for a in set_aside).most_common()], '',
        '## Booths', '',
        f'{len(booths)} booths; people per booth: smallest {counts[0]}, median {counts[len(counts) // 2]}, largest {counts[-1]}.',
        f"Booths without a polling station name: {', '.join(str(p) for p, n in sorted(booths.items()) if not n) or 'none'}.",
        f"Booths where loaded + set aside does not equal the sheet rows: {', '.join(map(str, sorted(mismatched))) or 'none'}.", '',
        '| Booth | People | Booth | People | Booth | People | Booth | People |', '|---:|---:|---:|---:|---:|---:|---:|---:|',
    ]
    parts = sorted(booths)
    for i in range(0, len(parts), 4):
        row = parts[i:i + 4]
        lines.append('| ' + ' | '.join(f'{p} | {by_part[p]}' for p in row) + ' |')
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    sys.exit(main())
