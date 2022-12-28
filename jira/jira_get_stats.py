#!/usr/bin/env python3

from jira import JIRA
import os
import sys

if len(sys.argv) < 2:
    print("Usage: jira_get_stats.py <username>")
    sys.exit(1)

assignee = sys.argv[1]

if 'JIRA_API_URL' in os.environ:
    jira_url = os.environ['JIRA_API_URL']
else:
    print("Environement variable JIRA_API_URL is not defined")
    sys.exit(1)

if 'JIRA_API_TOKEN' in os.environ:
    jira_token = os.environ['JIRA_API_TOKEN']
else:
    print("Environement variable JIRA_API_TOKEN is not defined")
    sys.exit(1)

jira = JIRA(jira_url, token_auth=jira_token)

sprints = jira.sprints(22)
closed_sprints = [s for s in sprints if s.state == 'closed']
index = len(closed_sprints)
print("date," +
      "completed," +
      "completed_timeoriginalestimate," +
      "time_by_issue," +
      "others," +
      "others_timeoriginalestimate")

for s in closed_sprints:
    if index <= 6:
        completed_issues = 0
        completed_timeoriginalestimate = 0
        time_by_issue = 0
        others_issues = 0
        others_timeoriginalestimate = 0
        issues = jira.search_issues('sprint = ' + str(s.id))
        for issue in issues:
            if issue.fields.assignee is not None and issue.fields.assignee.name == assignee:
                if issue.fields.status.name == 'Completed':
                    completed_issues += 1
                    if issue.fields.timeoriginalestimate is not None:
                        completed_timeoriginalestimate += issue.fields.timeoriginalestimate
                else:
                    others_issues += 1
                    if issue.fields.timeoriginalestimate is not None:
                        others_timeoriginalestimate += issue.fields.timeoriginalestimate

        if completed_issues != 0:
            time_by_issue = round(completed_timeoriginalestimate / completed_issues)

        print(s.name.split(" ")[2] + "," +
              str(completed_issues) + "," +
              str(completed_timeoriginalestimate) + "," +
              str(time_by_issue) + "," +
              str(others_issues) + "," +
              str(others_timeoriginalestimate))
    index -= 1
