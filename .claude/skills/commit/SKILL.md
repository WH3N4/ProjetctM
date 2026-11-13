---
name: commit
description: 변경을 커밋한다(푸시는 지시가 있을 때만). "커밋해"·"푸시해"·"올려줘"라고 할 때.
---
1. `git status --short` — 의도 밖 파일(빌드 산출물·임시)이 있으면 멈추고 보고.
2. 바꾼 파일을 경로로 add(`git add -A` 금지). 새 .gd·에셋이면 짝 `.uid`·`.import` 도 같이.
3. 메시지 = `feat|fix|refactor|chore|docs(범위): 한국어 요약` + 본문(왜 · 무엇으로 검증했나).
   한글·여러 줄이면 `git commit -F - <<'EOF' … EOF`.
4. 커밋 게이트가 막으면 원인을 고친다. 우회 금지.
5. 커밋까지면 `git log @{u}..HEAD --oneline` 으로 안 올린 커밋을 보고.
6. 푸시 지시가 있으면: "올려줘"처럼 애매하면 먼저 묻는다 → `git pull --rebase` → `git push`.
   푸시 게이트가 막으면 고쳐서 새 커밋으로 올린다.
출력 = 게이트 결과 · 해시·제목 · 미푸시 목록 또는 push 범위.
