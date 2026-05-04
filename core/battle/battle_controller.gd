class_name BattleController
extends Node


signal battle_end_requested
signal end_turn_requested

const STARTING_HAND_SIZE: int = 5

var state: BattleState
var events: BattleEvents

var _battle_end_pending: bool = false


func _init() -> void:
	events = BattleEvents.new()
	events.name = "BattleEvents"
	add_child(events)


func run_battle() -> void:
	events.dispatch(BattleStartedEvent.new())
	while not _battle_end_pending:
		state.refresh_energy()
		state.draw(STARTING_HAND_SIZE)
		await end_turn_requested
		state.discard_hand()
	events.dispatch(BattleEndedEvent.new())


func request_battle_end() -> void:
	_battle_end_pending = true
	end_turn_requested.emit()
	battle_end_requested.emit()


func request_end_turn() -> void:
	end_turn_requested.emit()
