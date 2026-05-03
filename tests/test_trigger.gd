extends GutTest


func test_trigger_exposes_play_draw_discard_and_end_of_turn_in_hand() -> void:
	var values: Array[int] = [
		Trigger.PLAY,
		Trigger.DRAW,
		Trigger.DISCARD,
		Trigger.END_OF_TURN_IN_HAND,
	]
	var unique: Dictionary = {}
	for v: int in values:
		unique[v] = true
	assert_eq(unique.size(), values.size(), "every Trigger constant should have a unique value")
