class_name CardEffect
extends Resource


@export var affects: int = TargetScope.SELECTED_TARGET
@export var trigger: int = Trigger.PLAY


func apply(_battle: BattleState, _source: Character, _selected_target: Character) -> void:
	pass
