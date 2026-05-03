extends GutTest


func test_target_type_exposes_enemy_self_all_enemies_and_none() -> void:
	var values: Array[int] = [
		TargetType.ENEMY,
		TargetType.SELF,
		TargetType.ALL_ENEMIES,
		TargetType.NONE,
	]
	var unique: Dictionary = {}
	for v: int in values:
		unique[v] = true
	assert_eq(unique.size(), values.size(), "every TargetType constant should have a unique value")
