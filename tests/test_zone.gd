extends GutTest


func test_zone_exposes_deck_hand_discard_and_exhaust() -> void:
	var values: Array[int] = [
		Zone.DECK,
		Zone.HAND,
		Zone.DISCARD,
		Zone.EXHAUST,
	]
	var unique: Dictionary = {}
	for v: int in values:
		unique[v] = true
	assert_eq(unique.size(), values.size(), "every Zone constant should have a unique value")
