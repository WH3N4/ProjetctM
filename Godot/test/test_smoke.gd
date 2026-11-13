extends GutTest
## GUT 가 푸시 게이트(tools/gate.sh push)에서 실제로 도는지 확인하는 스모크 테스트.


func test_gut_runs() -> void:
	assert_eq(1 + 1, 2, "GUT 가 돌고 있다")
