#!/usr/bin/env python3
"""Sends tools/import/out/people.jsonl to the database in batches.

Only people not loaded yet are added (import_people skips codes that exist),
and the closest-2026-entry notes of people already loaded are filled in
(import_voter_notes). Both functions need a one-time import token, opened and
closed by an admin around the run (see the import migrations).

    DASTAK_IMPORT_TOKEN_FILE=<file holding the token> python3 -I tools/import/send.py [--out DIR] [--v2]

Prints counts only, never voter details.
"""
import argparse
import json
import os
import re
import ssl
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BATCH = 1000


def app_config():
    """The project URL and publishable (public) key, as the app ships them."""
    with open(os.path.join(ROOT, 'app', 'lib', 'config.dart'), encoding='utf-8') as f:
        text = f.read()
    url = re.search(r"supabaseUrl\s*=.*?defaultValue:\s*'([^']+)'", text, re.S).group(1)
    key = re.search(r"supabaseKey\s*=.*?defaultValue:\s*'([^']+)'", text, re.S).group(1)
    return url, key


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--out', default=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
    ap.add_argument('--v2', action='store_true',
                    help='send version 2 instead: v2_updates.jsonl (import_voter_updates), '
                         'then v2_new.jsonl (import_people)')
    args = ap.parse_args()
    token_file = os.environ.get('DASTAK_IMPORT_TOKEN_FILE')
    if not token_file:
        sys.exit('set DASTAK_IMPORT_TOKEN_FILE')
    with open(token_file, encoding='utf-8') as f:
        token = f.read().strip()
    url, key = app_config()
    cafile = os.environ.get('SSL_CERT_FILE')
    context = ssl.create_default_context(cafile=cafile) if cafile else ssl.create_default_context()

    def call(fn, body):
        request = urllib.request.Request(
            f'{url}/rest/v1/rpc/{fn}', data=json.dumps(body, ensure_ascii=False).encode(), method='POST',
            headers={'apikey': key, 'Authorization': f'Bearer {key}', 'Content-Type': 'application/json'})
        with urllib.request.urlopen(request, context=context, timeout=120) as response:
            return json.loads(response.read())

    def lines(name):
        with open(os.path.join(args.out, name), encoding='utf-8') as f:
            return [json.loads(line) for line in f]

    if args.v2:
        rows = lines('v2_updates.jsonl')
        changed = 0
        for start in range(0, len(rows), BATCH):
            changed += call('import_voter_updates', {'p_token': token, 'p_rows': rows[start:start + BATCH]})
            print(f'updates: {min(start + BATCH, len(rows))}/{len(rows)} sent, {changed} people changed', flush=True)
        people = lines('v2_new.jsonl')
        added = 0
        for start in range(0, len(people), BATCH):
            added += call('import_people', {'p_token': token, 'p_people': people[start:start + BATCH]})
        print(f'new people: {len(people)} sent, {added} added')
        return

    people = lines('people.jsonl')

    notes = [{'code': p['code'], 'closest': p['closest']} for p in people if p.get('closest')]
    updated = 0
    for start in range(0, len(notes), BATCH):
        updated += call('import_voter_notes', {'p_token': token, 'p_rows': notes[start:start + BATCH]})
    print(f'notes: {len(notes)} sent, {updated} updated')

    added = 0
    for start in range(0, len(people), BATCH):
        added += call('import_people', {'p_token': token, 'p_people': people[start:start + BATCH]})
        print(f'people: {min(start + BATCH, len(people))}/{len(people)} sent, {added} added', flush=True)


if __name__ == '__main__':
    main()
