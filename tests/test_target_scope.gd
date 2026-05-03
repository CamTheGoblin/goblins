extends GutTest


func test_target_scope_exposes_selected_target_self_and_all_enemies() -> void:
	var values: Array[int] = [
		TargetScope.SELECTED_TARGET,
		TargetScope.SELF,
		TargetScope.ALL_ENEMIES,
	]
	var unique: Dictionary = {}
	for v: int in values:
		unique[v] = true
	assert_eq(unique.size(), values.size(), "every TargetScope constant should have a unique value")
