class_name CardView
extends Control


signal hover_entered_card(card_view: CardView)
signal hover_exited_card(card_view: CardView)
signal pressed_card(card_view: CardView, mouse_global_position: Vector2)

const CARD_SIZE: Vector2 = Vector2(140, 200)

var card_instance: CardInstance

@onready var _name_label: Label = $Name
@onready var _cost_label: Label = $Cost
@onready var _description_label: Label = $Description


func _ready() -> void:
	custom_minimum_size = CARD_SIZE
	size = CARD_SIZE
	pivot_offset = CARD_SIZE / 2.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_refresh()


func bind(instance: CardInstance) -> void:
	card_instance = instance
	if is_inside_tree():
		_refresh()


func tween_to(target: Transform2D, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property(self, "position", target.origin - pivot_offset, duration)
	tween.tween_property(self, "rotation", target.get_rotation(), duration)
	tween.tween_property(self, "scale", target.get_scale(), duration)


func snap_to_position(top_left: Vector2) -> void:
	position = top_left


func center_position() -> Vector2:
	return position + pivot_offset


func _refresh() -> void:
	if card_instance == null or card_instance.data == null:
		return
	var data: CardData = card_instance.data
	_name_label.text = data.name
	_cost_label.text = str(data.cost)
	_description_label.text = data.description


func _on_mouse_entered() -> void:
	hover_entered_card.emit(self)


func _on_mouse_exited() -> void:
	hover_exited_card.emit(self)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var btn: InputEventMouseButton = event
		if btn.button_index == MOUSE_BUTTON_LEFT and btn.pressed:
			pressed_card.emit(self, btn.global_position)
			accept_event()
