extends GutTest


func test_battle_state_holds_player_enemies_and_events() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)
	var player: Character = Character.new(40)
	var brute: Character = Character.new(18)
	var trickster: Character = Character.new(12)

	var battle: BattleState = BattleState.new(player, [brute, trickster] as Array[Character], bus)

	assert_same(battle.player, player, "BattleState should expose the player it was constructed with")
	assert_eq(battle.enemies.size(), 2, "BattleState should expose the enemy roster")
	assert_same(battle.enemies[0], brute, "BattleState should preserve enemy order")
	assert_same(battle.enemies[1], trickster, "BattleState should preserve enemy order")
	assert_same(battle.events, bus, "BattleState should expose the per-battle event bus")
