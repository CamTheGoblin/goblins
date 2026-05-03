extends GutTest


func _new_card() -> CardInstance:
	return CardInstance.new(CardData.new())


func _make_controller_with_battle() -> BattleController:
	var controller: BattleController = BattleController.new()
	add_child_autofree(controller)
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	controller.state = BattleState.new(player, [enemy] as Array[Character], controller.events)
	return controller


func _seed_deck(controller: BattleController, count: int) -> void:
	var cards: Array[CardInstance] = []
	for i: int in count:
		cards.append(_new_card())
	controller.state.deck = cards


func test_run_battle_dispatches_battle_started_synchronously_then_awaits_end() -> void:
	var controller: BattleController = _make_controller_with_battle()

	var started: Array[int] = []
	var ended: Array[int] = []
	var on_start: Callable = func(_e: BattleEvent) -> void:
		started.append(1)
	var on_end: Callable = func(_e: BattleEvent) -> void:
		ended.append(1)
	var _s: EventSubscription = controller.events.subscribe(BattleStartedEvent, on_start, 0)
	var _e: EventSubscription = controller.events.subscribe(BattleEndedEvent, on_end, 0)

	controller.run_battle.call()

	assert_eq(started.size(), 1, "battle_started should be dispatched synchronously when run_battle starts")
	assert_eq(ended.size(), 0, "battle_ended should not fire until end is explicitly requested")

	controller.request_battle_end()
	await wait_physics_frames(1)


func test_run_battle_draws_five_cards_into_hand_at_the_start_of_the_first_player_turn() -> void:
	var controller: BattleController = _make_controller_with_battle()
	_seed_deck(controller, 10)

	controller.run_battle.call()

	assert_eq(controller.state.hand.size(), 5, "first player turn should draw 5 cards into hand")
	assert_eq(controller.state.deck.size(), 5, "those 5 cards should come off the top of the deck")

	controller.request_battle_end()
	await wait_physics_frames(1)


func test_request_end_turn_discards_remaining_hand_and_starts_a_new_player_turn_with_a_fresh_draw() -> void:
	var controller: BattleController = _make_controller_with_battle()
	_seed_deck(controller, 12)

	controller.run_battle.call()
	assert_eq(controller.state.hand.size(), 5, "first turn should have drawn 5 cards")

	controller.request_end_turn()
	await wait_physics_frames(1)

	assert_eq(controller.state.discard.size(), 5, "all 5 cards should land in discard at end of turn")
	assert_eq(controller.state.hand.size(), 5, "the next player turn should immediately draw a fresh 5")
	assert_eq(controller.state.deck.size(), 2, "those draws should come off the remaining deck")

	controller.request_battle_end()
	await wait_physics_frames(1)


func test_multi_turn_cycling_drives_deck_through_hand_discard_and_reshuffle() -> void:
	var controller: BattleController = _make_controller_with_battle()
	controller.state.rng.seed = 1
	_seed_deck(controller, 8)

	controller.run_battle.call()
	controller.request_end_turn()
	await wait_physics_frames(1)
	controller.request_end_turn()
	await wait_physics_frames(1)
	controller.request_end_turn()
	await wait_physics_frames(1)

	assert_eq(controller.state.hand.size() + controller.state.deck.size() + controller.state.discard.size(), 8, "every original deck card should still be accounted for somewhere")
	assert_eq(controller.state.hand.size(), 5, "fourth player turn should have drawn a fresh 5 (with reshuffle)")

	controller.request_battle_end()
	await wait_physics_frames(1)


func test_request_battle_end_resumes_run_battle_and_dispatches_battle_ended() -> void:
	var controller: BattleController = _make_controller_with_battle()

	var ended: Array[int] = []
	var on_end: Callable = func(_e: BattleEvent) -> void:
		ended.append(1)
	var _sub: EventSubscription = controller.events.subscribe(BattleEndedEvent, on_end, 0)

	controller.run_battle.call()
	controller.request_battle_end()
	await wait_physics_frames(1)

	assert_eq(ended.size(), 1, "battle_ended should be dispatched once the controller is told to end")
