#!/bin/sh
# 게이트는 여기 하나 — git 훅 · Claude Stop 훅 · 사람 모두 이것만 부른다.
#   commit       스테이징 기준 전체 검사
#   changed      워킹트리의 바뀐 .gd 파싱만(Stop 훅용)
#   push A B     A..B 범위: WIP 커밋 · 파싱 · GUT
# 전제: Godot 프로젝트(project.godot)는 리포의 $PROJ 폴더 · GODOT = Godot *_console.exe 경로(슬래시 표기)
set -u
cd "$(git rev-parse --show-toplevel)" || exit 1
GODOT=${GODOT:-godot}
PROJ=Godot   # project.godot 가 있는 폴더(리포 루트 기준)
fail=0
err() { printf '✗ %s\n' "$*" >&2; fail=1; }
staged() { git diff --cached --name-only --no-renames --diff-filter="$1"; }
run_godot() { "$GODOT" --headless --path "$PROJ" "$@" </dev/null 2>&1; }

gd_ok() {  # $1 = 리포 기준 경로(Godot/…) → res:// 경로로 바꿔 파싱
  out=$(run_godot --check-only -s "res://${1#"$PROJ"/}") &&
    ! printf '%s' "$out" | grep -q 'SCRIPT ERROR\|Parse Error'
}
parse_gd() {  # $1 = 경로 목록(줄바꿈 구분) — 파이프 금지(서브셸이면 fail 이 사라진다)
  # addons/ 는 서드파티 — 파일 하나씩 따로 파싱하면 서로 의존하는 코드(GUT 등)에서 거짓 오류가 난다
  gd=$(printf '%s\n' "$1" | grep "^$PROJ/.*\.gd\$" | grep -v "^$PROJ/addons/" || true); [ -z "$gd" ] && return
  command -v "$GODOT" >/dev/null 2>&1 || { err "Godot 를 못 찾음 — 환경변수 GODOT 설정 후 Fork·VSCode 재시작"; return; }
  bad=$(printf '%s\n' "$gd" | while IFS= read -r f; do
    [ -f "$f" ] || continue
    gd_ok "$f" && continue
    # 한계: 새 class_name 은 클래스 캐시가 낡아 거짓 오류가 날 수 있다 → 한 번만 import 후 재시도
    if [ -z "${imported:-}" ]; then
      run_godot --import >/dev/null; imported=1
      gd_ok "$f" && continue
    fi
    # 오류 문장 + 바로 아래 'at: … (res://파일:줄)' 줄을 같이 보여 준다
    printf '%s\n%s\n' "$f" "$(printf '%s' "$out" | grep -A1 'SCRIPT ERROR' | grep -v '^--$' | head -6)"
  done)
  [ -n "$bad" ] && err "GDScript 오류
$bad"
}

case ${1:-commit} in
commit)
  git diff --cached -U0 | grep -qE '^\+(<<<<<<<|>>>>>>>) ' && err "충돌 표식이 남아 있음"
  # 스테이징된 내용의 크기로 잰다(LFS 를 켜면 포인터만 올라가므로 통과)
  big=$(staged AM | while IFS= read -r f; do [ "$(git cat-file -s ":$f")" -gt 52428800 ] && echo "$f"; done)
  [ -n "$big" ] && err "50MB 초과(GitHub 100MB 한도 · LFS 로): $big"
  sec=$(staged A | grep -E '\.(keystore|jks|p12|pem)$|(^|/)\.env|export_credentials' || true)
  [ -n "$sec" ] && err "비밀 파일: $sec"
  # 원본은 추적 중인데 짝 .uid/.import 가 추적 밖
  pair=$(git ls-files -o --exclude-standard -- '*.uid' '*.import' | while IFS= read -r u; do
           git cat-file -e ":${u%.*}" 2>/dev/null && echo "$u"; done)
  [ -n "$pair" ] && err "짝 파일도 add: $pair"
  # 원본은 지웠는데(=에디터 밖에서 이동·삭제) 짝이 남음
  orphan=$(staged D | while IFS= read -r f; do for s in uid import; do
             git cat-file -e ":$f.$s" 2>/dev/null && echo "$f.$s"; done; done)
  [ -n "$orphan" ] && err "고아 짝 파일(이동은 Godot FileSystem 독에서): $orphan"
  parse_gd "$(staged ACM)" ;;
changed)
  parse_gd "$(git diff HEAD --name-only --diff-filter=ACM; git ls-files -o --exclude-standard)" ;;
push)
  git log --format=%s "$2..$3" | grep -qiE '^(wip\b|fixup!|squash!)' && err "WIP·fixup 커밋 — Fork 에서 squash 후 push"
  files=$(git diff --name-only --diff-filter=ACM "$2" "$3")
  parse_gd "$files"
  if [ -f "$PROJ/addons/gut/gut_cmdln.gd" ] && printf '%s\n' "$files" | grep -qE "^$PROJ/.*\.(gd|tscn|tres)\$"; then
    out=$(run_godot -s res://addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit) ||
      err "GUT 테스트 실패
$(printf '%s\n' "$out" | tail -n 20)"
  fi ;;
esac
exit $fail
