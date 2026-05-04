class_name EnergyOrb
extends Control


@onready var _value_label: Label = $Value

var _state: BattleState
var _subscription: EventSubscription


func _exit_tree() -> void:
	if _subscription != null:
		_subscription.release()
		_subscription = null


func bind(state: BattleState) -> void:
	_state = state
	if _subscription != null:
		_subscription.release()
	_subscription = _state.events.subscribe(EnergyChangedEvent, _on_energy_changed, 0)
	_refresh()


func _on_energy_changed(_event: BattleEvent) -> void:
	_refresh()


func _refresh() -> void:
	if _state == null or _value_label == null:
		return
	_value_label.text = "%d/%d" % [_state.energy_current, _state.energy_max]
