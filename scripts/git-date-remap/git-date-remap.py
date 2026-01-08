#!/usr/bin/env python3
import sys
import subprocess
import datetime
import re
import argparse
import os
from datetime import timezone

def parse_date_str(s):
    if not s: return None
    try:
        if re.match(r'^\d{1,2}:\d{2}(:\d{2})?$', s):
            s = f"{datetime.datetime.now().strftime('%Y-%m-%d')}T{s}"
        clean = s.replace('Z', '+00:00')
        dt = datetime.datetime.fromisoformat(clean)
        if dt.tzinfo is None: dt = dt.astimezone()
        ts = int(dt.timestamp())
        off = int(dt.utcoffset().total_seconds())
        tz_str = f"{'+' if off >= 0 else '-'}{abs(off)//3600:02d}{(abs(off)%3600)//60:02d}"
        return ts, tz_str.encode('ascii')
    except ValueError: return None

def get_git_timestamp(refs, mode='min'):
    cmd = ['git', 'log'] + refs + ['--format=%at', '--author-date-order']
    res = subprocess.run(cmd, capture_output=True, text=True)
    ts_list = [int(l) for l in res.stdout.splitlines() if l.strip().isdigit()]
    return (min(ts_list) if mode == 'min' else max(ts_list)) if ts_list else None

def show_preview(t_min, t_max, t_dest_start, t_dest_end):
    # 現在のブランチ (HEAD) の変更対象を表示
    cmd = ['git', 'log', 'HEAD', f'--since={t_min}', '--format=%at|%s', '--author-date-order']
    res = subprocess.run(cmd, capture_output=True, text=True)
    
    def remap(ts):
        if ts < t_min: return ts
        if t_max <= t_min: return t_dest_start
        ratio = (ts - t_min) / (t_max - t_min)
        return int(t_dest_start + ratio * (t_dest_end - t_dest_start))

    previews = []
    for line in res.stdout.splitlines():
        if '|' not in line: continue
        ts_str, title = line.split('|', 1)
        ts = int(ts_str)
        if ts < t_min: continue
        old_d = datetime.datetime.fromtimestamp(ts).isoformat()
        new_d = datetime.datetime.fromtimestamp(remap(ts)).isoformat()
        previews.append(f"  {title[:50]:<50} | {old_d} -> {new_d}")
    
    if not previews:
        return False

    print("\nProposed changes (on current branch):")
    for p in reversed(previews):
        print(p)
    print(f"\nTotal remapped commits: {len(previews)}")
    return True

def main():
    parser = argparse.ArgumentParser(
        description="Linear remap of git commit dates using git-filter-repo (surgical mode).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Remap commits from 2023-01-01 until now to the period starting from 2025-01-01
  ./git-date-remap.py 2023-01-01 2025-01-01..

  # Remap activity from this morning (09:00) to this afternoon (13:00)
  ./git-date-remap.py 09:00 13:00..

  # Compress specific history range into a single day
  ./git-date-remap.py 2023-01-01..2024-01-01 2025-01-01..2025-01-02
"""
    )
    parser.add_argument("source", help="Source time (e.g. '2023-01-01') or range (e.g. 'HEAD~10..HEAD')")
    parser.add_argument("dest", help="Target range (e.g. '2025-01-01..' or '2025-01-01..2025-01-02')")
    parser.add_argument("-f", "--force", action="store_true", help="Skip confirmation prompt")
    parser.add_argument("-n", "--dry-run", action="store_true", help="Show proposed changes and exit")
    args = parser.parse_args()

    # 変換元の時間計算
    source_parts = args.source.split('..')
    if len(source_parts) == 2:
        res_a = parse_date_str(source_parts[0])
        res_b = parse_date_str(source_parts[1])
        t_min_orig = res_a[0] if res_a else get_git_timestamp([args.source], 'min')
        t_max_orig = res_b[0] if res_b else get_git_timestamp([args.source], 'max')
    else:
        res_s = parse_date_str(args.source)
        if res_s:
            t_min_orig = res_s[0]
            t_max_orig = get_git_timestamp(['HEAD'], 'max')
        else:
            t_min_orig = get_git_timestamp([args.source], 'min')
            t_max_orig = get_git_timestamp(['HEAD'], 'max')

    if t_min_orig is None:
        print("Error: No commits found."); sys.exit(1)

    # 変換後の時間計算
    dest_parts = args.dest.split('..')
    res_d_start = parse_date_str(dest_parts[0])
    if not res_d_start:
        print("Error: Invalid destination start."); sys.exit(1)
    t_dest_start, target_tz = res_d_start

    # タイムゾーンの明示的指定がない場合は None に
    if not (re.search(r'[+-]\d{2}:?\d{2}$', dest_parts[0]) or dest_parts[0].endswith('Z')):
        target_tz = None

    if len(dest_parts) > 1 and dest_parts[1]:
        res_d_end = parse_date_str(dest_parts[1])
        t_dest_end = res_d_end[0] if res_d_end else int(datetime.datetime.now().timestamp())
    else:
        t_dest_end = int(datetime.datetime.now(timezone.utc).timestamp())

    # プレビュー表示
    if not show_preview(t_min_orig, t_max_orig, t_dest_start, t_dest_end):
        print("No commits to remap in the specified range.")
        sys.exit(0)

    if args.dry_run:
        sys.exit(0)

    if not args.force:
        if input("\nProceed with rewriting history? [y/N]: ").lower() != 'y':
            print("Aborted."); sys.exit(0)

    # 書き換え対象の最初のコミットを特定する
    cmd_rev = ['git', 'log', 'HEAD', f'--since={t_min_orig}', '--format=%H', '--author-date-order']
    res_rev = subprocess.run(cmd_rev, capture_output=True, text=True)
    target_hashes = res_rev.stdout.splitlines()
    if not target_hashes:
        print("No commits found to rewrite."); sys.exit(0)
    
    # 最も古い書き換え対象コミットのハッシュ（一番下にあるもの）
    first_commit = target_hashes[-1]

    # 親があるか確認
    res_parent = subprocess.run(['git', 'rev-parse', '--verify', f'{first_commit}^'], 
                                capture_output=True, text=True)
    if res_parent.returncode == 0:
        refs_range = f'{first_commit}^..HEAD'
    else:
        # ルートコミットの場合は範囲指定なし（全体）
        refs_range = 'HEAD'

    # git-filter-repo の実行
    target_tz_repr = f"b'{target_tz.decode()}'" if target_tz else "None"
    callback_script = f"""
t_min = {t_min_orig}
t_max = {t_max_orig}
t_dest_start = {t_dest_start}
t_dest_end = {t_dest_end}
target_tz = {target_tz_repr}

def remap(ts):
    if ts < t_min: return ts
    if t_max <= t_min: return t_dest_start
    ratio = (ts - t_min) / (t_max - t_min)
    return int(t_dest_start + ratio * (t_dest_end - t_dest_start))

# Author Date
author_ts_b, author_tz_b = commit.author_date.split(b' ')
author_ts = int(author_ts_b)
new_author_ts = remap(author_ts)
if new_author_ts != author_ts or (target_tz and target_tz != author_tz_b):
    commit.author_date = b'%d %s' % (new_author_ts, target_tz if target_tz else author_tz_b)

# Committer Date
committer_ts_b, committer_tz_b = commit.committer_date.split(b' ')
committer_ts = int(committer_ts_b)
new_committer_ts = remap(committer_ts)
if new_committer_ts != committer_ts or (target_tz and target_tz != committer_tz_b):
    commit.committer_date = b'%d %s' % (new_committer_ts, target_tz if target_tz else committer_tz_b)
"""

    print("Applying changes via git-filter-repo...")
    # --refs <range>: 特定の範囲のコミットとその参照のみを対象にする
    # これにより、first_commit より前のコミットには一切触れなくなる
    cmd = ['git', 'filter-repo', '--commit-callback', callback_script, 
           '--refs', refs_range, '--partial', '--force']
    
    res = subprocess.run(cmd)
    if res.returncode == 0:
        print("\nSuccessfully remapped history.")
    else:
        sys.exit(res.returncode)

if __name__ == '__main__':
    main()
