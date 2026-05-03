class_name CharacterView
extends VBoxContainer


@export var label_text: String = "Character"

var _character: Character
var _events: BattleEvents
var _damage_subscription: EventSubscription

@onready var _name_label: Label = $NameLabel
@onready var _hp_bar: ProgressBar = $HpBar
@onready var _hp_label: Label = $HpLabel


func _ready() -> void:
	_name_label.text = label_text
	_refresh()


func bind(character: Character, events: BattleEvents) -> void:
	if _damage_subscription != null:
		_damage_subscription.release()
	_character = character
	_events = events
	_damage_subscription = events.subscribe(DamageEvent, _on_damage_event, 999)
	if is_inside_tree():
		_refresh()


func _exit_tree() -> void:
	if _damage_subscription != null:
		_damage_subscription.release()
		_damage_subscription = null


func _on_damage_event(event: BattleEvent) -> void:
	var damage: DamageEvent = event
	if damage.target != _character:
		return
	_refresh.call_deferred()


func _refresh() -> void:
	if _character == null:
		return
	_hp_bar.max_value = _character.max_hp
	_hp_bar.value = _character.current_hp
	_hp_label.text = "%d / %d" % [_character.current_hp, _character.max_hp]
