#!/bin/sh
# 되돌리기 어려운 명령 차단 — 권한 규칙은 명령 앞부분만 비교해서 중간에 붙은 --force 등을 놓친다
# 입력 = 훅 JSON(Bash·PowerShell 공통). ([^"&;|]|\\")* = 따옴표 친 인자는 넘되 다음 JSON 필드로는 안 넘어감
in=$(cat)
if printf '%s' "$in" | grep -qE -- '--no-verify|push([^"&;|]|\\")*(-f\b|--force)|reset --hard|clean -[a-z]*f|rm +-[a-zA-Z]*([rR][a-zA-Z]*f|f[a-zA-Z]*[rR])|rm +-[rR] +-f|git restore|branch -D' ||
   # PowerShell 재귀 삭제: Remove-Item·별칭 + -Recurse(약어 -r 포함). git rm 은 git 이 되살릴 수 있어 뺀다
   printf '%s' "$in" | sed 's/git rm//g' | grep -qiE -- '(remove-item|\b(ri|rm|rmdir|rd|del|erase))\s(([^"&;|]|\\")*\s)?-r'; then
  echo "막음: 훅 우회 · 강제 push · 되돌릴 수 없는 삭제 — 사용자에게 먼저 묻는다" >&2; exit 2
fi
