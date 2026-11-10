#!/usr/bin/env bash
# Idempotent GitHub board bootstrap for AIcoSystem.
# Requires: gh auth with project scope, python3, PyYAML (dnf install python3-pyyaml).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
YAML="$REPO_ROOT/docs/backlog/issues.yaml"
STATE="$REPO_ROOT/.github/bootstrap-state.json"
OWNER="${GITHUB_OWNER:-mFontecchio}"
PROJECT_TITLE="${PROJECT_TITLE:-AIcoSystem Roadmap}"

cd "$REPO_ROOT"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Run: gh auth login (and gh auth refresh -s project,read:project)" >&2
  exit 1
fi

repo_slug="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
if [[ -z "$repo_slug" ]]; then
  echo "Could not resolve GitHub repo. Push origin and retry." >&2
  exit 1
fi

python3 - <<'PY' "$YAML" "$STATE" "$OWNER" "$PROJECT_TITLE" "$repo_slug"
import json
import os
import subprocess
import sys

try:
    import yaml
except ImportError:
    sys.stderr.write("Install PyYAML: sudo dnf install python3-pyyaml\n")
    sys.exit(1)

yaml_path, state_path, owner, project_title, repo = sys.argv[1:6]

with open(yaml_path, encoding="utf-8") as f:
    data = yaml.safe_load(f)

state = {}
if os.path.isfile(state_path):
    with open(state_path, encoding="utf-8") as f:
        state = json.load(f)

def gh(argv, check=True):
    return subprocess.run(["gh", *argv], capture_output=True, text=True, check=check)

def label_exists(name):
    r = gh(["label", "list", "--json", "name", "-q", f".[] | select(.name==\"{name}\") | .name"], check=False)
    return name in (r.stdout or "")

all_labels = set()
for m in data.get("milestones", []):
    pass
for e in data.get("epics", []):
    for lb in e.get("labels", []):
        all_labels.add(lb)
for i in data.get("issues", []):
    for lb in i.get("labels", []):
        all_labels.add(lb)
all_labels.update(
    [
        "type:epic",
        "type:feature",
        "type:task",
        "type:docs",
        "type:adr",
        "area:scan",
        "area:catalog",
        "area:hash",
        "area:ops",
        "area:ui",
        "area:platform",
        "area:ci",
        "area:docs",
        "platform:linux",
        "platform:windows",
        "platform:both",
        "priority:p0",
        "priority:p1",
        "priority:p2",
    ]
)

for lb in sorted(all_labels):
    if not label_exists(lb):
        color = "ededed"
        if lb.startswith("priority:p0"):
            color = "b60205"
        elif lb.startswith("priority:p1"):
            color = "d93f0b"
        elif lb.startswith("type:epic"):
            color = "5319e7"
        gh(["label", "create", lb, "--color", color, "--description", lb], check=False)

milestone_numbers = state.get("milestones", {})
for m in data.get("milestones", []):
    name = m["name"]
    if name in milestone_numbers:
        continue
    owner_name, repo_name = repo.split("/")
    r = gh(
        [
            "api",
            "-X",
            "POST",
            f"repos/{owner_name}/{repo_name}/milestones",
            "-f",
            f"title={name}",
            "-f",
            f"description={m.get('description', '')}",
        ],
        check=False,
    )
    if r.returncode != 0 and "already exists" not in (r.stderr or "").lower():
        # list and match by title
        listed = gh(["api", f"repos/{repo}/milestones", "-q", ".[].number"], check=False)
        ms = gh(["api", f"repos/{repo}/milestones", "--paginate"], check=False)
        if ms.returncode == 0:
            for item in json.loads(ms.stdout or "[]"):
                if item.get("title") == name:
                    milestone_numbers[name] = item["number"]
                    break
    else:
        try:
            created = json.loads(r.stdout or "{}")
            if "number" in created:
                milestone_numbers[name] = created["number"]
        except json.JSONDecodeError:
            pass
    if name not in milestone_numbers:
        ms = gh(["api", f"repos/{repo}/milestones", "--paginate"], check=False)
        if ms.returncode == 0:
            for item in json.loads(ms.stdout or "[]"):
                if item.get("title") == name:
                    milestone_numbers[name] = item["number"]

project_number = state.get("project_number")
if not project_number:
    r = gh(
        ["project", "create", "--title", project_title, "--owner", owner, "--format", "json"],
        check=False,
    )
    if r.returncode == 0:
        try:
            project_number = json.loads(r.stdout).get("number")
        except json.JSONDecodeError:
            project_number = None
    if not project_number:
        listed = gh(["project", "list", "--owner", owner, "--format", "json"], check=False)
        if listed.returncode == 0:
            for p in json.loads(listed.stdout or "[]"):
                if p.get("title") == project_title:
                    project_number = p.get("number")
                    break

epic_issues = state.get("epic_issues", {})
for epic in data.get("epics", []):
    key = epic["key"]
    if key in epic_issues:
        continue
    ms_name = epic["milestone"]
    ms_flag = []
    if ms_name in milestone_numbers:
        ms_flag = ["--milestone", ms_name]
    label_args = []
    for lb in epic.get("labels", []):
        label_args.extend(["--label", lb])
    body = epic.get("body") or f"Epic for milestone {ms_name}. See docs/backlog/backlog.md."
    r = gh(
        [
            "issue",
            "create",
            "--title",
            epic["title"],
            "--body",
            body,
            *ms_flag,
            *label_args,
        ],
        check=False,
    )
    if r.returncode != 0:
        sys.stderr.write(r.stderr or "")
        continue
    url = (r.stdout or "").strip()
    num = url.rstrip("/").split("/")[-1] if url else None
    if num and num.isdigit():
        epic_issues[key] = int(num)
        if project_number:
            gh(
                [
                    "project",
                    "item-add",
                    str(project_number),
                    "--owner",
                    owner,
                    "--url",
                    url if url.startswith("http") else f"https://github.com/{repo}/issues/{num}",
                ],
                check=False,
            )

child_issues = state.get("child_issues", {})
titles_seen = set(child_issues.keys())
for issue in data.get("issues", []):
    title = issue["title"]
    if title in titles_seen:
        continue
    epic_key = issue["epic"]
    parent = epic_issues.get(epic_key)
    epic = next((e for e in data["epics"] if e["key"] == epic_key), None)
    ms_name = epic["milestone"] if epic else None
    ms_flag = ["--milestone", ms_name] if ms_name else []
    label_args = []
    for lb in issue.get("labels", []):
        label_args.extend(["--label", lb])
    body = issue.get("body", "")
    if parent:
        body = f"**Epic:** #{parent}\n\n{body}"
    size = issue.get("size", "M")
    body = f"**Size:** {size}\n\n{body}"
    r = gh(
        [
            "issue",
            "create",
            "--title",
            title,
            "--body",
            body,
            *ms_flag,
            *label_args,
        ],
        check=False,
    )
    if r.returncode != 0:
        sys.stderr.write(f"Failed: {title}\n{r.stderr}\n")
        continue
    url = (r.stdout or "").strip()
    num = url.rstrip("/").split("/")[-1] if url else None
    if num and num.isdigit():
        child_issues[title] = int(num)
        titles_seen.add(title)
        if project_number:
            gh(
                [
                    "project",
                    "item-add",
                    str(project_number),
                    "--owner",
                    owner,
                    "--url",
                    url if url.startswith("http") else f"https://github.com/{repo}/issues/{num}",
                ],
                check=False,
            )

os.makedirs(os.path.dirname(state_path), exist_ok=True)
out = {
    "repo": repo,
    "project_number": project_number,
    "project_title": project_title,
    "milestones": milestone_numbers,
    "epic_issues": epic_issues,
    "child_issues": child_issues,
}
with open(state_path, "w", encoding="utf-8") as f:
    json.dump(out, f, indent=2)

print(json.dumps({"project_number": project_number, "epics": len(epic_issues), "children": len(child_issues)}, indent=2))
PY

echo "Bootstrap state written to $STATE"
echo "Re-run is idempotent: existing titles in state are skipped."
