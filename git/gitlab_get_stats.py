#!/usr/bin/env python3

from datetime import datetime
from dateutil.relativedelta import relativedelta
import calendar
import gitlab
import os
import sys

if len(sys.argv) < 2:
    print("Usage: gitlab_get_stats.py <username>")
    sys.exit(1)

event_types = ['accepted', 'approved', 'closed', 'commented on', 'created', 'deleted',
               'joined', 'opened', 'pushed new', 'pushed to']

if 'GITLAB_API_PRIVATE_TOKEN' in os.environ:
    gitlab_token = os.environ['GITLAB_API_PRIVATE_TOKEN']
else:
    print("Environement variable GITLAB_API_PRIVATE_TOKEN is not defined")
    sys.exit(1)

if 'GITLAB_API_URL' in os.environ:
    gitlab_url = os.environ['GITLAB_API_URL']
else:
    print("Environement variable GITLAB_API_URL is not defined")
    sys.exit(1)

gl = gitlab.Gitlab(url=gitlab_url, private_token=gitlab_token)
gl.auth()

stats = {}
try:
    user = gl.users.list(username=sys.argv[1])[0]
except:
    print(f"Unable to get stats for user {sys.argv[1]}")
    sys.exit(1)

header = "month,"
for k in event_types:
    header += k + ","
print(header)

for m in range(6, 0, -1):
    stats.clear()

    for et in event_types:
        stats[et] = 0

    date = datetime.today() - relativedelta(months=m)
    first_day_month = date.replace(day=1)
    end_day = calendar.monthrange(date.year, date.month)[1]
    end_day_month = str(date.year) + "-" + str(date.month) + "-" + str(end_day)
    events = gl.events.list(user=user.id, iterator=True, after=first_day_month,
                            before=end_day_month)

    for event in events:
        if event.action_name in stats:
            stats[event.action_name] = stats[event.action_name] + 1
        else:
            print(f"WARNING: {event.action_name} not initialized")

    values = ""
    for v in stats.values():
        values += str(v) + ","
    print(date.strftime("%m/%Y,") + values)
