#!/bin/bash
# ===============================================
# buildOATutor.sh — Automate OATutor local build
# ===============================================

set -e  # Exit on error
set -o pipefail

# Define paths
REPO_PATH="/Users/jenniferkamrin/Documents/git/OATutor"
CONTENT_PATH="$REPO_PATH/src/content-sources/oatutor/Content"
BANK_URL="$CONTENT_PATH/Content-Files/Problem Bank URL.xlsx"
TOOL_SCRIPT="$CONTENT_PATH/OATutor-Tooling/content_script/final.py"

echo "🚀 Starting OATutor build process..."

# 3. Process local content
echo "📘 Processing local content..."
cd "$CONTENT_PATH"
python3 "$TOOL_SCRIPT" local "$BANK_URL"

# 4. Move files
echo "📦 Moving content files..."
cd "$REPO_PATH/src/content-sources/oatutor"
mkdir -p content-pool bkt-params
rsync -av --update "OpenStax Content/" "content-pool/" || echo "⚠️ No files to move from OpenStax Content"
mv bktParams.json bkt-params/defaultBKTParams.json || echo "⚠️ bktParams.json not found"
cp bkt-params/defaultBKTParams.json bkt-params/experimentalBKTParams.json

# 5. Preprocess problem pool
#echo "🧠 Preprocessing problem pool..."
#cd "$REPO_PATH/src/tools"
#node preprocessProblemPool.js || echo "⚠️ Might need to run preprocess again manually"
