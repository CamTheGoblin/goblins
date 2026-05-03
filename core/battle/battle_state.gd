class_name BattleState
extends RefCounted


var player: Character
var enemies: Array[Character]
var events: BattleEvents


func _init(starting_player: Character, starting_enemies: Array[Character], event_bus: BattleEvents) -> void:
	player = starting_player
	enemies = starting_enemies
	events = event_bus
