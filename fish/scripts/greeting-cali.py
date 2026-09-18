import json, subprocess, sys
from datetime import datetime

def get_events(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    return json.loads(r.stdout) if r.returncode == 0 and r.stdout.strip() else []

def format_events(events, now_str=None):
    if now_str:
        events = [e for e in events if e['allDay'] or e['start'][11:16] >= now_str or e['end'][11:16] > now_str]
    lines = []
    for e in events[:3]:
        if e['allDay']:
            lines.append(f'  {ALLDAY}all-day{R}  {TITLE}{e["summary"]}{R}')
        else:
            lines.append(f'  {TIME}{e["start"][11:16]}{R}  {TITLE}{e["summary"]}{R}')
    return lines

DIM = '\033[38;2;108;112;134m'  # overlay0
TIME = '\033[38;2;249;226;175m'  # yellow
TITLE = '\033[38;2;205;214;244m'  # text
ALLDAY = '\033[38;2;245;194;231m'  # pink
LABEL = '\033[38;2;137;180;250m'  # blue
R = '\033[0m'

now = datetime.now().strftime('%H:%M')
today = get_events(['cali', 'today', '--json'])
lines = format_events(today, now)
if lines:
    print(f'{LABEL}📅 Today:{R}')
    print('\n'.join(lines))
else:
    tomorrow = get_events(['cali', 'tomorrow', '--json'])
    lines = format_events(tomorrow)
    if lines:
        print(f'{LABEL}📅 Tomorrow:{R}')
        print('\n'.join(lines))
