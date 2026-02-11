#!/bin/bash
# 在 /workspace/koralcore 執行此腳本可建立 docs/ready_gate_0dc6ddf.patch
# 用法: bash scripts/create_ready_gate_patch.sh
# 或從任意 koralcore 目錄: bash /path/to/koralcore/scripts/create_ready_gate_patch.sh

set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/docs"
PATCH="$ROOT/docs/ready_gate_0dc6ddf.patch"

# 若 patch 已存在則跳過
if [ -f "$PATCH" ]; then
  echo "Patch already exists: $PATCH"
  exit 0
fi

# 從 git 產生（若在正確的 repo）
if git -C "$ROOT" rev-parse 0dc6ddf >/dev/null 2>&1; then
  git -C "$ROOT" show 0dc6ddf -p > "$PATCH"
  echo "Created $PATCH from git (0dc6ddf)"
  exit 0
fi

# 若無 0dc6ddf，嘗試從 GitHub raw 下載（需網路）
echo "0dc6ddf not in local repo. Try: git pull origin main"
echo "Or copy docs/ready_gate_0dc6ddf.patch from another clone."
exit 1
