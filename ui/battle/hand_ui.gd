class_name HandUI
extends Control


signal card_play_committed(card_instance: CardInstance, target: Character)

const CARD_VIEW_SCENE: PackedScene = preload("res://ui/battle/card_view.tscn")
const TARGET_ARROW_SCENE: PackedScene = preload("res://ui/battle/target_arrow.tscn")
const DRAG_THRESHOLD_PX: float = 6.0

@export var params: HandLayoutParams
@export var tween_duration: float = 0.18
@export var nontargeted_play_threshold_offset_y: float = -180.0
@export var targeted_drag_stage_offset: Vector2 = Vector2(0.0, -260.0)

var _state: BattleState
var _enemy_views: Array[CharacterView] = []
var _player_view: CharacterView
var _energy_subscription: EventSubscription

var _card_views: Array[CardView] = []
var _hovered_index: int = -1
var _dragged_index: int = -1
var _drag_armed: bool = false
var _drag_active: bool = false
var _drag_start_global: Vector2 = Vector2.ZERO
var _drag_is_targeted: bool = false

var _target_arrow: TargetArrow


func _ready() -> void:
	_target_arrow = TARGET_ARROW_SCENE.instantiate()
	add_child(_target_arrow)
	if params == null:
		params = HandLayoutParams.new()


func bind(state: BattleState, player_view: CharacterView, enemy_views: Array[CharacterView]) -> void:
	_state = state
	_player_view = player_view
	_enemy_views = enemy_views
	if _energy_subscription != null:
		_energy_subscription.release()
	_energy_subscription = _state.events.subscribe(EnergyChangedEvent, _on_energy_changed, 0)


func _exit_tree() -> void:
	if _energy_subscription != null:
		_energy_subscription.release()
		_energy_subscription = null


func _on_energy_changed(_event: BattleEvent) -> void:
	_refresh_affordability()


func render(hand: Array[CardInstance]) -> void:
	for view: CardView in _card_views:
		view.queue_free()
	_card_views.clear()
	_hovered_index = -1
	_dragged_index = -1
	_drag_armed = false
	_drag_active = false
	_target_arrow.hide_arrow()
	for instance: CardInstance in hand:
		var view: CardView = CARD_VIEW_SCENE.instantiate()
		view.bind(instance)
		view.hover_entered_card.connect(_on_card_hover_entered)
		view.hover_exited_card.connect(_on_card_hover_exited)
		view.pressed_card.connect(_on_card_pressed)
		add_child(view)
		_card_views.append(view)
	_apply_layout(false)
	_refresh_affordability()


func _refresh_affordability() -> void:
	if _state == null:
		return
	for view: CardView in _card_views:
		view.set_affordable(_can_afford(view.card_instance))


func _apply_layout(animate: bool) -> void:
	var transforms: Array[Transform2D] = HandLayout.compute_layout(_card_views.size(), _hovered_index, _dragged_index, params)
	for i: int in _card_views.size():
		var view: CardView = _card_views[i]
		if i == _dragged_index and _drag_active:
			continue
		if animate:
			view.tween_to(transforms[i], tween_duration)
		else:
			var pivot: Vector2 = view.pivot_offset
			view.position = transforms[i].origin - pivot
			view.rotation = transforms[i].get_rotation()
			view.scale = transforms[i].get_scale()


func _on_card_hover_entered(view: CardView) -> void:
	if _drag_armed or _drag_active:
		return
	var idx: int = _card_views.find(view)
	if idx == -1 or idx == _hovered_index:
		return
	_hovered_index = idx
	_bring_to_front(view)
	_apply_layout(true)


func _on_card_hover_exited(view: CardView) -> void:
	if _drag_armed or _drag_active:
		return
	var idx: int = _card_views.find(view)
	if idx != _hovered_index:
		return
	_hovered_index = -1
	_apply_layout(true)


func _on_card_pressed(view: CardView, mouse_global_position: Vector2) -> void:
	if _drag_armed or _drag_active:
		return
	var idx: int = _card_views.find(view)
	if idx == -1:
		return
	_drag_armed = true
	_dragged_index = idx
	_drag_start_global = mouse_global_position
	_drag_is_targeted = _is_targeted(view.card_instance)
	_bring_to_front(view)


func _input(event: InputEvent) -> void:
	if not _drag_armed and not _drag_active:
		return
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		if not _drag_active:
			if motion.global_position.distance_to(_drag_start_global) >= DRAG_THRESHOLD_PX:
				_drag_active = true
				_apply_layout(true)
				if _drag_is_targeted:
					_target_arrow.show_arrow(_stage_drag_position(), motion.global_position)
				else:
					_follow_cursor(motion.global_position)
		else:
			if _drag_is_targeted:
				_target_arrow.update_endpoints(_stage_drag_position(), motion.global_position)
				_target_arrow.set_valid_target(_enemy_under(motion.global_position) != null)
			else:
				_follow_cursor(motion.global_position)
	elif event is InputEventMouseButton:
		var btn: InputEventMouseButton = event
		if btn.button_index == MOUSE_BUTTON_LEFT and not btn.pressed:
			_resolve_release(btn.global_position)


func _resolve_release(release_global_position: Vector2) -> void:
	var dragged_view: CardView = _card_views[_dragged_index] if _dragged_index >= 0 and _dragged_index < _card_views.size() else null
	var was_active: bool = _drag_active
	_target_arrow.hide_arrow()
	_drag_armed = false
	_drag_active = false
	if not was_active or dragged_view == null:
		_dragged_index = -1
		_apply_layout(true)
		return
	var played: bool = false
	if _can_afford(dragged_view.card_instance):
		if _drag_is_targeted:
			var enemy: Character = _enemy_under(release_global_position)
			if enemy != null:
				_commit_play(dragged_view.card_instance, enemy)
				played = true
		else:
			var card_top_global: float = dragged_view.global_position.y
			var threshold_global_y: float = global_position.y + nontargeted_play_threshold_offset_y
			if card_top_global <= threshold_global_y and _state != null:
				_commit_play(dragged_view.card_instance, _state.player)
				played = true
	if played:
		return
	_dragged_index = -1
	_apply_layout(true)


func _can_afford(card_instance: CardInstance) -> bool:
	if _state == null or card_instance == null:
		return false
	return card_instance.can_play(_state)


func _commit_play(card_instance: CardInstance, target: Character) -> void:
	if _state == null:
		return
	var cost: int = card_instance.data.cost
	card_instance.play(_state, target)
	_state.spend_energy(cost)
	_state.discard_from_hand(card_instance)
	card_play_committed.emit(card_instance, target)


func _follow_cursor(mouse_global_position: Vector2) -> void:
	var view: CardView = _card_views[_dragged_index]
	view.global_position = mouse_global_position - view.pivot_offset
	view.rotation = 0.0
	view.scale = Vector2.ONE


func _stage_drag_position() -> Vector2:
	return global_position + targeted_drag_stage_offset


func _enemy_under(mouse_global_position: Vector2) -> Character:
	for i: int in _enemy_views.size():
		var view: CharacterView = _enemy_views[i]
		if view.get_global_rect().has_point(mouse_global_position):
			if i < _state.enemies.size():
				var enemy: Character = _state.enemies[i]
				if enemy.current_hp > 0:
					return enemy
	return null


func _bring_to_front(view: CardView) -> void:
	move_child(view, get_child_count() - 1)
	move_child(_target_arrow, get_child_count() - 1)


func _is_targeted(instance: CardInstance) -> bool:
	if instance == null or instance.data == null:
		return false
	return instance.data.target_type == TargetType.ENEMY or instance.data.target_type == TargetType.ALL_ENEMIES
