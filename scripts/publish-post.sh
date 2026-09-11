#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <markdown-file> [asset-file ...]" >&2
  echo "  Moves the post + assets into content/posts/<slug>/, marks it published, commits it." >&2
  exit 1
}

[ $# -ge 1 ] || usage

MD_FILE="$1"
shift
ASSETS=("$@")

[ -f "$MD_FILE" ] || { echo "Error: markdown file not found: $MD_FILE" >&2; exit 1; }

REPO_ROOT="$(git rev-parse --show-toplevel)"

SLUG="$(basename "$MD_FILE" .md \
  | tr '[:upper:]' '[:lower:]' \
  | tr ' _' '-' \
  | tr -cs 'a-z0-9-' '-' \
  | sed 's/^-*//; s/-*$//')"

[ -n "$SLUG" ] || { echo "Error: could not derive a slug from filename: $MD_FILE" >&2; exit 1; }

POST_DIR="$REPO_ROOT/content/posts/$SLUG"

if [ -e "$POST_DIR" ]; then
  echo "Error: post already exists: $POST_DIR" >&2
  exit 1
fi

mkdir -p "$POST_DIR"
cp "$MD_FILE" "$POST_DIR/index.md"

for asset in "${ASSETS[@]}"; do
  [ -f "$asset" ] || { echo "Error: asset not found: $asset" >&2; exit 1; }
  cp "$asset" "$POST_DIR/"
done

# Ensure the post is published (draft: false), whether or not front matter already has a draft field.
if grep -q '^draft:' "$POST_DIR/index.md"; then
  sed -i '' 's/^draft:.*/draft: false/' "$POST_DIR/index.md"
else
  awk '
    NR==1 && $0=="---" { print; print "draft: false"; next }
    { print }
  ' "$POST_DIR/index.md" > "$POST_DIR/index.md.tmp" && mv "$POST_DIR/index.md.tmp" "$POST_DIR/index.md"
fi

TITLE="$(grep '^title:' "$POST_DIR/index.md" | head -1 | sed 's/^title:[[:space:]]*//; s/^"//; s/"$//')"
[ -n "$TITLE" ] || TITLE="$SLUG"

cd "$REPO_ROOT"
git add "content/posts/$SLUG"
git commit -m "Post: $TITLE"

echo ""
read -r -p "Push to live now? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  git push
  echo "Pushed — Cloudflare Pages will build and deploy shortly."
else
  echo "Committed locally only. Run 'git push' from $REPO_ROOT when you're ready to publish."
fi
