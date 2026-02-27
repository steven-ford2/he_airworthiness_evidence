#!/usr/bin/env bash
set -euo pipefail

# PURPOSE:
# 1) Create issues from the CSV (title/body/labels).
# 2) Optionally add each issue to a GitHub Project (Projects v2) and set custom fields.
#
# PREREQS:
# - gh CLI authenticated: gh auth status
# - jq installed
#
# USAGE:
#   ./import_issues_and_project.sh <OWNER> <REPO> <CSV_PATH> [PROJECT_NUMBER]
#
# NOTES:
# - GitHub Issues import from CSV is not natively supported by gh.
# - This script uses a simple CSV parser in python for robustness.
# - Project field setting requires GraphQL and the project node ID.

OWNER="${1:?OWNER required}"
REPO="${2:?REPO required}"
CSV_PATH="${3:?CSV_PATH required}"
PROJECT_NUMBER="${4:-}"   # optional

python3 - <<'PY'
import csv, sys, subprocess, shlex, json, os
owner=os.environ["OWNER"]; repo=os.environ["REPO"]; path=os.environ["CSV_PATH"]
rows=[]
with open(path,newline="",encoding="utf-8") as f:
    r=csv.DictReader(f)
    for row in r:
        rows.append(row)

def run(cmd):
    print(">", " ".join(shlex.quote(c) for c in cmd))
    subprocess.check_call(cmd)

for row in rows:
    title=row["Title"].strip()
    body=row["Body"].strip()
    labels=[l.strip() for l in row["Labels"].split(",") if l.strip()]
    # create issue
    cmd=["gh","issue","create","--repo",f"{owner}/{repo}","--title",title,"--body",body]
    for lab in labels:
        cmd += ["--label", lab]
    # If you want to add a due date, add it in the body or use a custom field in Projects.
    run(cmd)
PY

echo "Issues created."

if [[ -n "${PROJECT_NUMBER}" ]]; then
  echo "Project import step not executed automatically in this skeleton."
  echo "Reason: setting Projects v2 fields requires obtaining project ID + field IDs via GraphQL."
  echo "Next: use the GraphQL snippet in README below to wire this up for your org."
fi
