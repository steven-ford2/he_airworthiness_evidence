#!/usr/bin/env bash
set -euo pipefail

# ---- Fixed for your repo ----
OWNER="steven-ford2"
REPO="he_airworthiness_evidence"
PROJECT_NUMBER="2"

# ---- Inputs ----
CSV_PATH="${1:?CSV path required, e.g. he_repo_2026_ultra_granular_with_effort.csv}"

echo "OWNER=$OWNER"
echo "REPO=$REPO"
echo "PROJECT_NUMBER=$PROJECT_NUMBER"
echo "CSV=$CSV_PATH"

# ---------- Resolve Project ID (USER project) ----------
PROJECT_ID="$(gh api graphql -f query='
query($login:String!, $number:Int!) {
  user(login:$login) {
    projectV2(number:$number) { id title }
  }
}' -f login="$OWNER" -F number="$PROJECT_NUMBER" --jq '.data.user.projectV2.id')"

if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
  echo "ERROR: Could not resolve ProjectV2 ID. Ensure Project #$PROJECT_NUMBER exists under user $OWNER."
  exit 1
fi

PROJECT_TITLE="$(gh api graphql -f query='
query($login:String!, $number:Int!) {
  user(login:$login) {
    projectV2(number:$number) { title }
  }
}' -f login="$OWNER" -F number="$PROJECT_NUMBER" --jq '.data.user.projectV2.title')"

echo "Project resolved: $PROJECT_TITLE"
echo "Project ID: $PROJECT_ID"

# ---------- Fetch fields (IDs + select options) ----------
FIELDS_JSON="$(gh api graphql -f query='
query($id:ID!) {
  node(id:$id) {
    ... on ProjectV2 {
      fields(first:100) {
        nodes {
          __typename
          ... on ProjectV2FieldCommon { id name }
          ... on ProjectV2SingleSelectField { name id options { id name } }
        }
      }
    }
  }
}' -f id="$PROJECT_ID")"

field_id_by_name () {
  echo "$FIELDS_JSON" | jq -r --arg NAME "$1" '
    .data.node.fields.nodes[]
    | select(.name==$NAME)
    | .id
  ' | head -n 1
}

select_option_id () {
  local field_name="$1"
  local option_name="$2"
  echo "$FIELDS_JSON" | jq -r --arg FIELD "$field_name" --arg OPT "$option_name" '
    .data.node.fields.nodes[]
    | select(.name==$FIELD)
    | .options[]
    | select(.name==$OPT)
    | .id
  ' | head -n 1
}

FIELD_STATUS_ID="$(field_id_by_name "Status")"
FIELD_DUEDATE_ID="$(field_id_by_name "Due Date")"
FIELD_EFFORT_ID="$(field_id_by_name "Effort")"
FIELD_HOURSPLANNED_ID="$(field_id_by_name "Hours Planned")"

STATUS_BACKLOG_OPT_ID=""
if [[ -n "${FIELD_STATUS_ID}" && "${FIELD_STATUS_ID}" != "null" ]]; then
  STATUS_BACKLOG_OPT_ID="$(select_option_id "Status" "Backlog")"
fi

# Effort option IDs (mapped)
EFFORT_XS_OPT_ID=""
EFFORT_S_OPT_ID=""
EFFORT_M_OPT_ID=""
EFFORT_L_OPT_ID=""
EFFORT_XL_OPT_ID=""
if [[ -n "${FIELD_EFFORT_ID}" && "${FIELD_EFFORT_ID}" != "null" ]]; then
  EFFORT_XS_OPT_ID="$(select_option_id "Effort" "XS (≤1h)")"
  EFFORT_S_OPT_ID="$(select_option_id "Effort" "S (1–2h)")"
  EFFORT_M_OPT_ID="$(select_option_id "Effort" "M (3–5h)")"
  EFFORT_L_OPT_ID="$(select_option_id "Effort" "L (6–10h)")"
  EFFORT_XL_OPT_ID="$(select_option_id "Effort" "XL (10h+)")"
fi

echo "Field IDs:"
echo "  Status:        ${FIELD_STATUS_ID:-<missing>}"
echo "  Due Date:      ${FIELD_DUEDATE_ID:-<missing>}"
echo "  Effort:        ${FIELD_EFFORT_ID:-<missing>}"
echo "  Hours Planned: ${FIELD_HOURSPLANNED_ID:-<missing>}"
echo "Status Backlog option ID: ${STATUS_BACKLOG_OPT_ID:-<missing>}"
echo "Effort option IDs:"
echo "  XS: ${EFFORT_XS_OPT_ID:-<missing>}"
echo "  S : ${EFFORT_S_OPT_ID:-<missing>}"
echo "  M : ${EFFORT_M_OPT_ID:-<missing>}"
echo "  L : ${EFFORT_L_OPT_ID:-<missing>}"
echo "  XL: ${EFFORT_XL_OPT_ID:-<missing>}"

export OWNER REPO CSV_PATH PROJECT_ID
export FIELD_STATUS_ID FIELD_DUEDATE_ID FIELD_EFFORT_ID FIELD_HOURSPLANNED_ID STATUS_BACKLOG_OPT_ID
export EFFORT_XS_OPT_ID EFFORT_S_OPT_ID EFFORT_M_OPT_ID EFFORT_L_OPT_ID EFFORT_XL_OPT_ID

# ---------- Create issues + add to Project + set fields ----------
python3 - <<'PY'
import csv, os, subprocess, shlex, json, re

OWNER=os.environ["OWNER"]
REPO=os.environ["REPO"]
CSV_PATH=os.environ["CSV_PATH"]
PROJECT_ID=os.environ["PROJECT_ID"]

FIELD_STATUS_ID=os.environ.get("FIELD_STATUS_ID","")
FIELD_DUEDATE_ID=os.environ.get("FIELD_DUEDATE_ID","")
FIELD_EFFORT_ID=os.environ.get("FIELD_EFFORT_ID","")
FIELD_HOURSPLANNED_ID=os.environ.get("FIELD_HOURSPLANNED_ID","")
STATUS_BACKLOG_OPT_ID=os.environ.get("STATUS_BACKLOG_OPT_ID","")

EFFORT_OPT = {
    "XS": os.environ.get("EFFORT_XS_OPT_ID",""),
    "S":  os.environ.get("EFFORT_S_OPT_ID",""),
    "M":  os.environ.get("EFFORT_M_OPT_ID",""),
    "L":  os.environ.get("EFFORT_L_OPT_ID",""),
    "XL": os.environ.get("EFFORT_XL_OPT_ID",""),
}

def run(cmd, capture=False):
    print(">", " ".join(shlex.quote(c) for c in cmd))
    if capture:
        return subprocess.check_output(cmd, text=True)
    subprocess.check_call(cmd)
    return ""

def gh_graphql(query, variables):
    cmd=["gh","api","graphql","-f",f"query={query}"]
    for k,v in variables.items():
        cmd += ["-f", f"{k}={v}"]
    out = run(cmd, capture=True)
    return json.loads(out)

def get_issue_node_id(number:int):
    q = """
    query($owner:String!, $name:String!, $number:Int!) {
      repository(owner:$owner, name:$name) {
        issue(number:$number) { id }
      }
    }
    """
    data = gh_graphql(q, {"owner":OWNER, "name":REPO, "number":number})
    return data["data"]["repository"]["issue"]["id"]

def add_to_project(issue_node_id:str):
    q = """
    mutation($projectId:ID!, $contentId:ID!) {
      addProjectV2ItemById(input:{projectId:$projectId, contentId:$contentId}) {
        item { id }
      }
    }
    """
    data = gh_graphql(q, {"projectId":PROJECT_ID, "contentId":issue_node_id})
    return data["data"]["addProjectV2ItemById"]["item"]["id"]

def set_single_select(item_id:str, field_id:str, option_id:str):
    q = """
    mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $optionId:String!) {
      updateProjectV2ItemFieldValue(input:{
        projectId:$projectId,
        itemId:$itemId,
        fieldId:$fieldId,
        value:{ singleSelectOptionId:$optionId }
      }) { projectV2Item { id } }
    }
    """
    gh_graphql(q, {"projectId":PROJECT_ID, "itemId":item_id, "fieldId":field_id, "optionId":option_id})

def set_date(item_id:str, field_id:str, date_str:str):
    q = """
    mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $date:String!) {
      updateProjectV2ItemFieldValue(input:{
        projectId:$projectId,
        itemId:$itemId,
        fieldId:$fieldId,
        value:{ date:$date }
      }) { projectV2Item { id } }
    }
    """
    gh_graphql(q, {"projectId":PROJECT_ID, "itemId":item_id, "fieldId":field_id, "date":date_str})

def set_number(item_id:str, field_id:str, number_val:float):
    q = """
    mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $num:Float!) {
      updateProjectV2ItemFieldValue(input:{
        projectId:$projectId,
        itemId:$itemId,
        fieldId:$fieldId,
        value:{ number:$num }
      }) { projectV2Item { id } }
    }
    """
    gh_graphql(q, {"projectId":PROJECT_ID, "itemId":item_id, "fieldId":field_id, "num":number_val})

def create_issue(title:str, body:str, labels:list[str]):
    cmd=["gh","issue","create","--repo",f"{OWNER}/{REPO}","--title",title,"--body",body]
    for lab in labels:
        cmd += ["--label", lab]
    out = run(cmd, capture=True).strip()
    m=re.search(r"/issues/(\d+)$", out)
    if not m:
        raise RuntimeError(f"Could not parse issue number from: {out}")
    return int(m.group(1)), out

with open(CSV_PATH, newline="", encoding="utf-8") as f:
    reader=csv.DictReader(f)
    rows=list(reader)

print(f"Rows to import: {len(rows)}")

for idx,row in enumerate(rows, start=1):
    title=row.get("Title","").strip()
    body=row.get("Body","").strip()
    labels=[l.strip() for l in row.get("Labels","").split(",") if l.strip()]
    due=row.get("Due Date","").strip()
    effort=row.get("Effort","").strip()
    hours=row.get("Hours Planned","").strip()

    if not title:
        print(f"Skip row {idx}: missing Title")
        continue

    issue_number, issue_url = create_issue(title, body, labels)
    issue_node_id = get_issue_node_id(issue_number)
    item_id = add_to_project(issue_node_id)

    # Status -> Backlog
    if FIELD_STATUS_ID and FIELD_STATUS_ID != "null" and STATUS_BACKLOG_OPT_ID and STATUS_BACKLOG_OPT_ID != "null":
        set_single_select(item_id, FIELD_STATUS_ID, STATUS_BACKLOG_OPT_ID)

    # Due Date
    if FIELD_DUEDATE_ID and FIELD_DUEDATE_ID != "null" and due:
        set_date(item_id, FIELD_DUEDATE_ID, due)

    # Effort mapping XS/S/M/L/XL
    if FIELD_EFFORT_ID and FIELD_EFFORT_ID != "null" and effort:
        opt_id = EFFORT_OPT.get(effort.strip(), "")
        if opt_id and opt_id != "null":
            set_single_select(item_id, FIELD_EFFORT_ID, opt_id)
        else:
            print(f"Warn: Effort option ID missing for value {effort!r}. Check your Project Effort options.")

    # Hours Planned
    if FIELD_HOURSPLANNED_ID and FIELD_HOURSPLANNED_ID != "null" and hours:
        try:
            set_number(item_id, FIELD_HOURSPLANNED_ID, float(hours))
        except Exception as e:
            print(f"Warn: could not set Hours Planned for issue {issue_number}: {e}")

    print(f"[{idx}/{len(rows)}] Imported: {issue_url}")

print("Import complete.")
PY
