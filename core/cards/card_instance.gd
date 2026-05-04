class_name CardInstance
extends RefCounted


var data: CardData


func _init(card_data: CardData) -> void:
	data = card_data


func play(battle: BattleState, target: Character) -> void:
	for effect: CardEffect in data.effects:
		effect.apply(battle, battle.player, target)


func can_play(battle: BattleState) -> bool:
	return data.cost <= battle.energy_current
