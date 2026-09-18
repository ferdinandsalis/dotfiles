import json, subprocess
r = subprocess.run(['remi', 'ls', '--json'], capture_output=True, text=True)
if r.returncode == 0 and r.stdout.strip():
    items = json.loads(r.stdout)
    if items:
        DIM = '\033[38;2;108;112;134m'
        TITLE = '\033[38;2;205;214;244m'
        TAG = '\033[38;2;137;180;250m'
        DUE = '\033[38;2;249;226;175m'
        LABEL = '\033[38;2;137;180;250m'
        FLAG = '\033[38;2;243;139;168m'
        R = '\033[0m'
        print(f'{LABEL}📋 {len(items)} pending:{R}')
        for item in items[:3]:
            parts = []
            if item.get('flagged'): parts.append(f'{FLAG}🚩{R}')
            parts.append(f'{TITLE}{item["title"]}{R}')
            if item.get('dueDate'): parts.append(f'{DUE}{item["dueDate"][:10]}{R}')
            tags = item.get('tags', [])
            if tags: parts.append(f'{TAG}{" ".join("#" + t for t in tags)}{R}')
            print('  • ' + '  '.join(parts))
        if len(items) > 3:
            print(f'  {DIM}... and {len(items) - 3} more{R}')
