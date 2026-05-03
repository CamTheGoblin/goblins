class_name HandLayout
extends RefCounted


static func compute_layout(hand_size: int, hovered_index: int, dragged_index: int, params: HandLayoutParams) -> Array[Transform2D]:
	var transforms: Array[Transform2D] = []
	if hand_size == 0:
		return transforms
	var effective_hover: int = hovered_index
	if dragged_index >= 0 and dragged_index == hovered_index:
		effective_hover = -1
	if hand_size == 1:
		var single: Transform2D = Transform2D.IDENTITY
		if effective_hover == 0:
			single = single.scaled(Vector2(params.hover_scale, params.hover_scale))
			single.origin.y -= params.hover_lift
		transforms.append(single)
		return transforms
	var half_angle: float = deg_to_rad(params.total_fan_angle_deg) / 2.0
	var step: float = (2.0 * half_angle) / float(hand_size - 1)
	for i: int in hand_size:
		var angle: float = -half_angle + float(i) * step
		var x: float = params.arc_radius * sin(angle)
		var y: float = params.arc_radius * (1.0 - cos(angle))
		var scale_factor: float = 1.0
		var rotation: float = angle
		if i == effective_hover:
			y -= params.hover_lift
			scale_factor = params.hover_scale
			rotation = 0.0
		elif effective_hover >= 0 and i == effective_hover - 1:
			x -= params.neighbor_displacement
		elif effective_hover >= 0 and i == effective_hover + 1:
			x += params.neighbor_displacement
		var t: Transform2D = Transform2D(rotation, Vector2(x, y))
		t = t.scaled_local(Vector2(scale_factor, scale_factor))
		transforms.append(t)
	return transforms
