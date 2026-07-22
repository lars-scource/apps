#!/bin/zsh
# Deploy apps-site to GitHub Pages (public repo: apps)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
GH="${GH:-$ROOT/../indkvartering-app/tools/gh}"
if [[ ! -x "$GH" ]]; then
  GH="$(command -v gh || true)"
fi
if [[ -z "${GH}" || ! -x "$GH" ]]; then
  echo "gh CLI not found. Install GitHub CLI or place binary at indkvartering-app/tools/gh"
  exit 1
fi

cd "$ROOT"

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "Not logged in to GitHub. Run:"
  echo "  $GH auth login -h github.com -p https -w"
  exit 1
fi

USER="$("$GH" api user -q .login)"
REPO="apps"
URL="https://${USER}.github.io/${REPO}/"

echo "GitHub user: $USER"
echo "Target: $USER/$REPO → $URL"

if ! "$GH" repo view "$USER/$REPO" >/dev/null 2>&1; then
  echo "Creating public repo $USER/$REPO ..."
  "$GH" repo create "$REPO" --public --description "App Store support & privacy (personal)" --source=. --remote=origin --push
else
  if [[ ! -d .git ]]; then
    git init
    git branch -M main
    git remote add origin "https://github.com/${USER}/${REPO}.git" 2>/dev/null || \
      git remote set-url origin "https://github.com/${USER}/${REPO}.git"
  fi
  git add -A
  if git diff --cached --quiet; then
    echo "No file changes to commit."
  else
    git commit -m "Update apps site (privacy + support)"
  fi
  git push -u origin main
fi

# Enable GitHub Pages from main branch root
echo "Enabling GitHub Pages..."
"$GH" api -X POST "repos/${USER}/${REPO}/pages" \
  -f "build_type=legacy" \
  -f "source[branch]=main" \
  -f "source[path]=/" 2>/dev/null || \
"$GH" api -X PUT "repos/${USER}/${REPO}/pages" \
  -f "build_type=legacy" \
  -f "source[branch]=main" \
  -f "source[path]=/" 2>/dev/null || true

# Prefer official pages API with JSON
"$GH" api -X PUT "repos/${USER}/${REPO}/pages" \
  --input - <<'EOF' 2>/dev/null || true
{"build_type":"legacy","source":{"branch":"main","path":"/"}}
EOF

echo ""
echo "Done. After ~1 minute use these App Store URLs:"
echo "  Support:  ${URL}"
echo "  Privacy:  ${URL}privacy.html"
echo ""
echo "Open privacy page:"
echo "  open ${URL}privacy.html"
