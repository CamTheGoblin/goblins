class_name DamageEffect
extends CardEffect


@export var amount: int = 0


func apply(battle: BattleState, source: Character, selected_target: Character) -> void:
	var event: DamageEvent = DamageEvent.new()
	event.source = source
	event.target = selected_target
	event.amount = amount
	battle.events.dispatch(event)
	if event.cancelled:
		return
	selected_target.take_damage(event.amount)
