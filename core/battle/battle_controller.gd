class_name BattleController
extends Node


signal end_requested

var state: BattleState
var events: BattleEvents


func _init() -> void:
	events = BattleEvents.new()
	events.name = "BattleEvents"
	add_child(events)


func run_battle() -> void:
	events.dispatch(BattleStartedEvent.new())
	await end_requested
	events.dispatch(BattleEndedEvent.new())


func request_end() -> void:
	end_requested.emit()
