#!/bin/sh
# 턴 끝에 바뀐 .gd 파싱 — 깨졌으면 exit 2 로 Claude 에게 돌려보낸다(같은 상황에선 한 번만)
cd "$CLAUDE_PROJECT_DIR" || exit 0
grep -q '"stop_hook_active": *true' && exit 0
sh tools/gate.sh changed || exit 2
