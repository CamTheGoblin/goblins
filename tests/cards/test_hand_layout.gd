extends GutTest


func _params() -> HandLayoutParams:
	var p: HandLayoutParams = HandLayoutParams.new()
	return p


func test_empty_hand_returns_empty_transform_array() -> void:
	var transforms: Array[Transform2D] = HandLayout.compute_layout(0, -1, -1, _params())

	assert_eq(transforms.size(), 0, "an empty hand should yield no transforms")


func test_single_card_sits_at_layout_origin_with_identity_rotation_and_unit_scale() -> void:
	var transforms: Array[Transform2D] = HandLayout.compute_layout(1, -1, -1, _params())

	assert_eq(transforms.size(), 1, "a one-card hand should yield exactly one transform")
	var t: Transform2D = transforms[0]
	assert_almost_eq(t.origin.x, 0.0, 0.001, "single card should be centered horizontally at the layout origin")
	assert_almost_eq(t.origin.y, 0.0, 0.001, "single card should sit at y=0 (no arc droop with one card)")
	assert_almost_eq(t.get_rotation(), 0.0, 0.001, "single card should not be rotated")
	assert_almost_eq(t.get_scale().x, 1.0, 0.001, "single card scale should be 1")
	assert_almost_eq(t.get_scale().y, 1.0, 0.001, "single card scale should be 1")


func test_three_cards_are_x_ordered_left_to_right_with_center_card_straightest() -> void:
	var transforms: Array[Transform2D] = HandLayout.compute_layout(3, -1, -1, _params())

	assert_eq(transforms.size(), 3, "three-card hand should yield three transforms")
	assert_lt(transforms[0].origin.x, transforms[1].origin.x, "card 0 should be left of card 1")
	assert_lt(transforms[1].origin.x, transforms[2].origin.x, "card 1 should be left of card 2")
	assert_lt(transforms[0].get_rotation(), 0.0, "leftmost card should rotate counter-clockwise (negative angle)")
	assert_almost_eq(transforms[1].get_rotation(), 0.0, 0.001, "middle card should not be rotated")
	assert_gt(transforms[2].get_rotation(), 0.0, "rightmost card should rotate clockwise (positive angle)")
	assert_lt(absf(transforms[1].get_rotation()), absf(transforms[0].get_rotation()), "middle card should be straighter than the left edge card")
	assert_lt(absf(transforms[1].get_rotation()), absf(transforms[2].get_rotation()), "middle card should be straighter than the right edge card")


func test_card_positions_lie_on_an_arc_of_params_arc_radius_below_the_origin() -> void:
	var params: HandLayoutParams = _params()
	params.arc_radius = 600.0
	params.total_fan_angle_deg = 30.0
	var arc_center: Vector2 = Vector2(0.0, params.arc_radius)

	var transforms: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)

	for i: int in transforms.size():
		var distance: float = transforms[i].origin.distance_to(arc_center)
		assert_almost_eq(distance, params.arc_radius, 0.01, "card %d should be exactly arc_radius from the arc center" % i)
	assert_gt(transforms[0].origin.y, 0.0, "the leftmost card should sit below the layout origin (frown-shaped arc)")
	assert_gt(transforms[transforms.size() - 1].origin.y, 0.0, "the rightmost card should sit below the layout origin (frown-shaped arc)")
	assert_almost_eq(transforms[2].origin.y, 0.0, 0.001, "the middle card should sit at y=0 (highest point of the arc)")


func test_more_cards_pack_more_tightly_with_a_smaller_per_card_angular_step() -> void:
	var params: HandLayoutParams = _params()
	var five: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)
	var ten: Array[Transform2D] = HandLayout.compute_layout(10, -1, -1, params)

	var step_at_five: float = absf(five[1].get_rotation() - five[0].get_rotation())
	var step_at_ten: float = absf(ten[1].get_rotation() - ten[0].get_rotation())

	assert_lt(step_at_ten, step_at_five, "10-card hand should pack tighter angularly than 5-card")
	assert_almost_eq(absf(ten[0].get_rotation()), absf(ten[ten.size() - 1].get_rotation()), 0.001, "10-card fan should be symmetric around 0")
	assert_lt(absf(ten[0].get_rotation()), deg_to_rad(params.total_fan_angle_deg), "fan never exceeds the configured total angle")


func test_hovering_middle_card_lifts_it_upward_and_scales_it_up() -> void:
	var params: HandLayoutParams = _params()
	params.hover_lift = 100.0
	params.hover_scale = 1.25

	var baseline: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)
	var hovered: Array[Transform2D] = HandLayout.compute_layout(5, 2, -1, params)

	assert_almost_eq(hovered[2].origin.y, baseline[2].origin.y - params.hover_lift, 0.01, "hovered card should sit hover_lift pixels above its baseline (smaller Y in screen coords)")
	assert_almost_eq(hovered[2].get_scale().x, params.hover_scale, 0.001, "hovered card x-scale should equal hover_scale")
	assert_almost_eq(hovered[2].get_scale().y, params.hover_scale, 0.001, "hovered card y-scale should equal hover_scale")


func test_hovering_an_off_center_card_straightens_its_rotation_toward_zero() -> void:
	var params: HandLayoutParams = _params()
	var baseline: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)
	var hovered: Array[Transform2D] = HandLayout.compute_layout(5, 1, -1, params)

	assert_lt(absf(hovered[1].get_rotation()), absf(baseline[1].get_rotation()), "hovered off-center card should be straighter than its baseline angle")


func test_hovering_middle_card_displaces_both_neighbors_outward_by_neighbor_displacement() -> void:
	var params: HandLayoutParams = _params()
	params.neighbor_displacement = 40.0
	var baseline: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)
	var hovered: Array[Transform2D] = HandLayout.compute_layout(5, 2, -1, params)

	assert_almost_eq(hovered[1].origin.x, baseline[1].origin.x - params.neighbor_displacement, 0.01, "left neighbor should slide left by neighbor_displacement")
	assert_almost_eq(hovered[3].origin.x, baseline[3].origin.x + params.neighbor_displacement, 0.01, "right neighbor should slide right by neighbor_displacement")


func test_hovering_leftmost_card_lifts_it_and_only_displaces_its_one_right_neighbor() -> void:
	var params: HandLayoutParams = _params()
	params.neighbor_displacement = 40.0
	var baseline: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)
	var hovered: Array[Transform2D] = HandLayout.compute_layout(5, 0, -1, params)

	assert_almost_eq(hovered[0].origin.y, baseline[0].origin.y - params.hover_lift, 0.01, "leftmost card should still get the hover lift")
	assert_almost_eq(hovered[1].origin.x, baseline[1].origin.x + params.neighbor_displacement, 0.01, "the one right neighbor should slide right by neighbor_displacement")
	assert_almost_eq(hovered[2].origin.x, baseline[2].origin.x, 0.01, "non-neighbor cards should be unaffected")
	assert_almost_eq(hovered[3].origin.x, baseline[3].origin.x, 0.01, "non-neighbor cards should be unaffected")
	assert_almost_eq(hovered[4].origin.x, baseline[4].origin.x, 0.01, "non-neighbor cards should be unaffected")


func test_dragging_a_card_keeps_layout_size_intact_and_returns_baseline_transform_for_that_slot() -> void:
	var params: HandLayoutParams = _params()
	var baseline: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)
	var dragging: Array[Transform2D] = HandLayout.compute_layout(5, -1, 2, params)

	assert_eq(dragging.size(), 5, "drag should not shrink the returned array; caller indexes by slot")
	for i: int in 5:
		assert_almost_eq(dragging[i].origin.x, baseline[i].origin.x, 0.01, "non-dragged-non-hovered slot %d should match baseline x" % i)
		assert_almost_eq(dragging[i].origin.y, baseline[i].origin.y, 0.01, "non-dragged-non-hovered slot %d should match baseline y" % i)


func test_drag_wins_over_hover_when_the_same_slot_is_both_hovered_and_dragged() -> void:
	var params: HandLayoutParams = _params()
	var baseline: Array[Transform2D] = HandLayout.compute_layout(5, -1, -1, params)
	var both: Array[Transform2D] = HandLayout.compute_layout(5, 2, 2, params)

	assert_almost_eq(both[2].origin.x, baseline[2].origin.x, 0.01, "dragged slot should keep its baseline x even with hover set")
	assert_almost_eq(both[2].origin.y, baseline[2].origin.y, 0.01, "dragged slot should not be lifted when also hovered")
	assert_almost_eq(both[2].get_scale().x, 1.0, 0.001, "dragged slot should keep unit scale even with hover set")
	assert_almost_eq(both[2].get_scale().y, 1.0, 0.001, "dragged slot should keep unit scale even with hover set")
	assert_almost_eq(both[1].origin.x, baseline[1].origin.x, 0.01, "neighbor of a dragged-hovered slot should not be displaced (drag suppresses hover entirely)")
	assert_almost_eq(both[3].origin.x, baseline[3].origin.x, 0.01, "neighbor of a dragged-hovered slot should not be displaced (drag suppresses hover entirely)")
