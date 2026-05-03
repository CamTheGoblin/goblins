extends GutTest


func _make_battle(player: Character, enemies: Array[Character]) -> BattleState:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)
	return BattleState.new(player, enemies, bus)


func test_apply_with_selected_target_reduces_target_hp_by_amount() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])

	var effect: DamageEffect = DamageEffect.new()
	effect.amount = 6
	effect.affects = TargetScope.SELECTED_TARGET

	effect.apply(battle, player, enemy)

	assert_eq(enemy.current_hp, 12, "selected target should lose hp equal to the damage amount")
	assert_eq(player.current_hp, 40, "non-targeted characters should be untouched")


func test_apply_dispatches_a_damage_event_carrying_source_target_and_amount() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])

	var observed: Array[DamageEvent] = []
	var observer: Callable = func(event: BattleEvent) -> void:
		var damage: DamageEvent = event
		observed.append(damage)
	var _sub: EventSubscription = battle.events.subscribe(DamageEvent, observer, 0)

	var effect: DamageEffect = DamageEffect.new()
	effect.amount = 6

	effect.apply(battle, player, enemy)

	assert_eq(observed.size(), 1, "applying damage should dispatch exactly one DamageEvent")
	assert_same(observed[0].source, player, "DamageEvent should carry the source")
	assert_same(observed[0].target, enemy, "DamageEvent should carry the target")
	assert_eq(observed[0].amount, 6, "DamageEvent should carry the requested amount")


func test_apply_uses_amount_after_pipeline_mutation_when_assigning_damage() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])

	var doubler: Callable = func(event: BattleEvent) -> void:
		var damage: DamageEvent = event
		damage.amount *= 2
	var _sub: EventSubscription = battle.events.subscribe(DamageEvent, doubler, 1)

	var effect: DamageEffect = DamageEffect.new()
	effect.amount = 6

	effect.apply(battle, player, enemy)

	assert_eq(enemy.current_hp, 6, "applied damage should reflect pipeline mutations (6 doubled to 12)")


func test_apply_does_not_reduce_hp_when_a_subscriber_cancels_the_event() -> void:
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	var battle: BattleState = _make_battle(player, [enemy] as Array[Character])

	var canceller: Callable = func(event: BattleEvent) -> void:
		event.cancelled = true
	var _sub: EventSubscription = battle.events.subscribe(DamageEvent, canceller, 1)

	var effect: DamageEffect = DamageEffect.new()
	effect.amount = 6

	effect.apply(battle, player, enemy)

	assert_eq(enemy.current_hp, 18, "cancelled damage event should leave hp untouched")
