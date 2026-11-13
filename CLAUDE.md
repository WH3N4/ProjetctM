# ProjetctM(ProjectMusket) — Claude 작업 규칙
Godot 4.7 · GDScript(정적 타입) · 1인 개발 · 브랜치 = main(실험만 짧은 가지)
Godot 프로젝트 = `Godot/`(project.godot 위치). 리포 루트에는 하네스(.claude · .githooks · tools)만 둔다.

## 수정
- .tscn/.tres/project.godot 를 텍스트로 고치기 전엔 묻는다(기본은 에디터). 고칠 땐 ext_resource id·uid 를 새로 만들지 않는다.
- 파일 이동·이름변경·삭제는 Godot FileSystem 독에서. 셸로 해야 하면 .uid·.import 짝을 같이 옮긴다.
- .godot/ · *.import · *.uid 는 생성물 — 편집 금지.
- 완료 전 `sh tools/gate.sh changed`(Stop 훅이 자동으로도 돈다). 로직을 바꿨으면 Godot/test/ 에 GUT 테스트 하나.
- Stop 훅이 내가 건드리지 않은 .gd 의 오류를 보고하면(사용자가 에디터에서 작업 중) 고치지 말고 알리기만 한다.
- 오류는 근본 원인부터. 범위 밖 발견은 TODO.md 에 한 줄 적고 복귀.

## 커밋·푸시
- 스킬 commit 을 따른다. «커밋해» = 커밋까지, push 는 지시가 있을 때만.
- --no-verify · force push · reset --hard 금지(훅이 막는다).
