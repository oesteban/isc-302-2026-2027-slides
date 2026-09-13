#!/usr/bin/env bash
# Create the git-ignored local roster and the per-day symlinks roulette.js
# looks for. Run from anywhere inside the checkout.
#
#   tools/roster-local.sh          # create from the committed placeholder
#   $EDITOR roster.local.yml       # put the real names in
#
# Nothing this script creates can enter git: every path it touches is matched
# by the roster.local.yml rule in .gitignore. The committed roster.yml stays
# synthetic and is what gets published.
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
cd "$root"

if [ ! -e roster.local.yml ]; then
  {
    echo "# roster.local.yml - the real names. Git-ignored; never commit it."
    # the placeholder minus its own header comment
    sed '/^[[:space:]]*#/d' roster.yml
  } > roster.local.yml
  echo "created roster.local.yml (copy of the placeholder)"
fi

for d in week*/day*/; do
  depth=$(printf '%s' "$d" | tr -cd '/' | wc -c)
  up=$(for _ in $(seq "$depth"); do printf '../'; done)
  ln -sfn "${up}roster.local.yml" "${d}roster.local.yml"
done
echo "linked roster.local.yml into $(ls -d week*/day*/ | wc -l) decks"

# Prove the protection is live.
if git check-ignore -q roster.local.yml; then
  echo "ok: roster.local.yml is ignored by .gitignore"
else
  echo "WARNING: roster.local.yml is NOT ignored - do not put real names in it" >&2
  exit 1
fi
