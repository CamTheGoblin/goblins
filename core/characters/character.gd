class_name Character
extends RefCounted


var max_hp: int
var current_hp: int


func _init(starting_max_hp: int) -> void:
	max_hp = starting_max_hp
	current_hp = starting_max_hp


func take_damage(amount: int) -> void:
	current_hp = maxi(current_hp - amount, 0)
