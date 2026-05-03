class_name HandView
extends HBoxContainer


const PLACEHOLDER_SIZE: Vector2 = Vector2(80, 120)
const PLACEHOLDER_COLOR: Color = Color(0.32, 0.45, 0.65)


func render(hand: Array[CardInstance]) -> void:
	for child: Node in get_children():
		child.queue_free()
	for card: CardInstance in hand:
		var placeholder: ColorRect = ColorRect.new()
		placeholder.custom_minimum_size = PLACEHOLDER_SIZE
		placeholder.color = PLACEHOLDER_COLOR
		var label: Label = Label.new()
		label.text = card.data.name if card.data != null else "?"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		placeholder.add_child(label)
		add_child(placeholder)
