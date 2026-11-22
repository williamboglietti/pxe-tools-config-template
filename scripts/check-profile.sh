#!/usr/bin/env bash
# Validate pxe-tools.json with the validator PXE Tools itself uses, at the
# committed HEAD (uncommitted changes are not seen, as on the server).
set -euo pipefail

validator_commit=8d0936828c94c406254422e859534943422565d8
validator_sha256=0bcf0cf10f97f3aed0ff9dc45a749db38ad3e2c86d93d1cc47965eb7d64f58bd
validator_url="https://raw.githubusercontent.com/williamboglietti/pxe-tools/${validator_commit}/app/repository_scope.py"

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
curl --fail --silent --show-error --location --proto '=https' --max-time 30 \
  --output "$work/repository_scope.py" "$validator_url"
echo "${validator_sha256}  $work/repository_scope.py" | sha256sum --check --quiet -

python3 -I - "$work" "$PWD" <<'PY'
import json
import sys

sys.path.insert(0, sys.argv[1])
from repository_scope import ScopeError, load_profile

try:
    profile = load_profile(sys.argv[2], "pxe-tools.json")
except ScopeError as error:
    sys.exit(f"pxe-tools.json is invalid: {error}")
print(json.dumps({key: profile[key] for key in ("name", "presets_path", "playbooks")}, indent=2))
PY
