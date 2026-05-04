extends GutTest


class RecordingEffect:
	extends CardEffect
	var call_count: int = 0
	var last_battle: BattleState
	var last_source: Character
	var last_target: Character

	func apply(battle: BattleState, source: Character, selected_target: Character) -> void:
		call_count += 1
		last_battle = battle
		last_source = source
		last_target = selected_target


func _make_battle(player: Character, enemies: Array[Character]) -> BattleState:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)
	return BattleState.new(player, enemies, bus)


func test_play_invokes_each_effect_apply_with_battle_player_and_target() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])

	var first: RecordingEffect = RecordingEffect.new()
	var second: RecordingEffect = RecordingEffect.new()
	var data: CardData = CardData.new()
	data.effects = [first, second] as Array[CardEffect]
	var card: CardInstance = CardInstance.new(data)

	card.play(battle, enemy)

	assert_eq(first.call_count, 1, "first effect should be invoked exactly once")
	assert_same(first.last_battle, battle, "first effect should receive the battle")
	assert_same(first.last_source, player, "source should default to the player")
	assert_same(first.last_target, enemy, "target should be the one passed to play")
	assert_eq(second.call_count, 1, "second effect should also be invoked")
	assert_same(second.last_target, enemy, "every effect should see the played-against target")


func test_can_play_is_true_when_card_cost_equals_current_energy() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])
	battle.spend_energy(2)

	var data: CardData = CardData.new()
	data.cost = 1
	var card: CardInstance = CardInstance.new(data)

	var result: bool = card.can_play(battle)
	assert_true(result, "a 1-cost card with exactly 1 energy remaining should be playable")


func test_can_play_is_false_when_card_cost_exceeds_current_energy() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])
	battle.spend_energy(2)

	var data: CardData = CardData.new()
	data.cost = 2
	var card: CardInstance = CardInstance.new(data)

	var result: bool = card.can_play(battle)
	assert_false(result, "a 2-cost card should not be playable when only 1 energy remains")


func test_play_strike_drops_enemy_hp_through_the_full_pipeline() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])

	var strike_damage: DamageEffect = DamageEffect.new()
	strike_damage.amount = 6
	var data: CardData = CardData.new()
	data.name = "Strike"
	data.cost = 1
	data.target_type = TargetType.ENEMY
	data.effects = [strike_damage] as Array[CardEffect]
	var card: CardInstance = CardInstance.new(data)

	card.play(battle, enemy)

	assert_eq(enemy.current_hp, 12, "playing Strike at 6 damage should drop the enemy from 18 to 12")
