extends GutTest


func _make_battle() -> BattleState:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)
	var player: Character = Character.new(40)
	var brute: Character = Character.new(18)
	var trickster: Character = Character.new(12)
	return BattleState.new(player, [brute, trickster] as Array[Character], bus)


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


func test_battle_state_starts_with_four_empty_zone_piles() -> void:
	var battle: BattleState = _make_battle()

	assert_eq(battle.deck.size(), 0, "deck should start empty")
	assert_eq(battle.hand.size(), 0, "hand should start empty")
	assert_eq(battle.discard.size(), 0, "discard should start empty")
	assert_eq(battle.exhaust.size(), 0, "exhaust should start empty")


func _new_card() -> CardInstance:
	return CardInstance.new(CardData.new())


func test_move_top_of_deck_to_hand_pulls_first_deck_card_into_hand_and_returns_it() -> void:
	var battle: BattleState = _make_battle()
	var top: CardInstance = _new_card()
	var middle: CardInstance = _new_card()
	var bottom: CardInstance = _new_card()
	battle.deck = [top, middle, bottom] as Array[CardInstance]

	var drawn: CardInstance = battle.move_top_of_deck_to_hand()

	assert_same(drawn, top, "drawing should return the top-of-deck card")
	assert_eq(battle.hand, [top] as Array[CardInstance], "the drawn card should land in hand")
	assert_eq(battle.deck, [middle, bottom] as Array[CardInstance], "the drawn card should be removed from the deck")


func test_discard_from_hand_moves_card_from_hand_to_discard_pile() -> void:
	var battle: BattleState = _make_battle()
	var keeper: CardInstance = _new_card()
	var played: CardInstance = _new_card()
	battle.hand = [keeper, played] as Array[CardInstance]

	battle.discard_from_hand(played)

	assert_eq(battle.hand, [keeper] as Array[CardInstance], "the discarded card should be removed from hand")
	assert_eq(battle.discard, [played] as Array[CardInstance], "the discarded card should land on the discard pile")


func test_exhaust_from_hand_moves_card_from_hand_to_exhaust_pile() -> void:
	var battle: BattleState = _make_battle()
	var keeper: CardInstance = _new_card()
	var burned: CardInstance = _new_card()
	battle.hand = [keeper, burned] as Array[CardInstance]

	battle.exhaust_from_hand(burned)

	assert_eq(battle.hand, [keeper] as Array[CardInstance], "the exhausted card should be removed from hand")
	assert_eq(battle.exhaust, [burned] as Array[CardInstance], "the exhausted card should land on the exhaust pile")


func test_reshuffle_moves_every_discarded_card_into_the_deck_and_empties_discard() -> void:
	var battle: BattleState = _make_battle()
	var a: CardInstance = _new_card()
	var b: CardInstance = _new_card()
	var c: CardInstance = _new_card()
	battle.discard = [a, b, c] as Array[CardInstance]

	battle.reshuffle_discard_into_deck()

	assert_eq(battle.discard.size(), 0, "discard should be empty after reshuffle")
	assert_eq(battle.deck.size(), 3, "deck should contain every reshuffled card")
	assert_true(battle.deck.has(a), "deck should contain card a after reshuffle")
	assert_true(battle.deck.has(b), "deck should contain card b after reshuffle")
	assert_true(battle.deck.has(c), "deck should contain card c after reshuffle")


func test_reshuffle_is_deterministic_for_a_given_rng_seed() -> void:
	var cards: Array[CardInstance] = [
		_new_card(), _new_card(), _new_card(), _new_card(), _new_card(), _new_card(), _new_card(), _new_card(),
	]

	var first: BattleState = _make_battle()
	first.rng.seed = 42
	first.discard = cards.duplicate() as Array[CardInstance]
	first.reshuffle_discard_into_deck()

	var second: BattleState = _make_battle()
	second.rng.seed = 42
	second.discard = cards.duplicate() as Array[CardInstance]
	second.reshuffle_discard_into_deck()

	assert_eq(first.deck, second.deck, "the same rng seed should produce the same shuffle order")


func test_reshuffle_actually_permutes_for_at_least_one_seed() -> void:
	var cards: Array[CardInstance] = [
		_new_card(), _new_card(), _new_card(), _new_card(), _new_card(), _new_card(), _new_card(), _new_card(),
	]
	var battle: BattleState = _make_battle()
	battle.rng.seed = 42
	battle.discard = cards.duplicate() as Array[CardInstance]

	battle.reshuffle_discard_into_deck()

	assert_ne(battle.deck, cards, "the reshuffled deck should not match the original order for seed 42")


func test_draw_pulls_n_cards_from_top_of_deck_into_hand() -> void:
	var battle: BattleState = _make_battle()
	var first: CardInstance = _new_card()
	var second: CardInstance = _new_card()
	var third: CardInstance = _new_card()
	var fourth: CardInstance = _new_card()
	battle.deck = [first, second, third, fourth] as Array[CardInstance]

	battle.draw(3)

	assert_eq(battle.hand, [first, second, third] as Array[CardInstance], "draw should pull cards from the top of the deck in order")
	assert_eq(battle.deck, [fourth] as Array[CardInstance], "drawn cards should be removed from the deck")


func test_draw_stops_at_hand_size_cap_of_ten_even_if_deck_has_more() -> void:
	var battle: BattleState = _make_battle()
	var deck_cards: Array[CardInstance] = []
	for i: int in 15:
		deck_cards.append(_new_card())
	battle.deck = deck_cards.duplicate() as Array[CardInstance]

	battle.draw(15)

	assert_eq(battle.hand.size(), 10, "hand should cap at the 10-card max")
	assert_eq(battle.deck.size(), 5, "draws past the cap should not consume more deck cards")
	for i: int in 10:
		assert_same(battle.hand[i], deck_cards[i], "the first 10 deck cards should be the ones drawn into hand")


func test_draw_reshuffles_discard_into_deck_when_deck_empties_mid_draw() -> void:
	var battle: BattleState = _make_battle()
	battle.rng.seed = 7
	var on_top: CardInstance = _new_card()
	var in_discard_a: CardInstance = _new_card()
	var in_discard_b: CardInstance = _new_card()
	battle.deck = [on_top] as Array[CardInstance]
	battle.discard = [in_discard_a, in_discard_b] as Array[CardInstance]

	battle.draw(3)

	assert_eq(battle.hand.size(), 3, "draw should pull all 3 cards even though the deck only had 1")
	assert_eq(battle.discard.size(), 0, "discard should be empty after the auto-reshuffle")
	assert_eq(battle.deck.size(), 0, "the deck should be drained of all reshuffled cards")
	assert_true(battle.hand.has(on_top), "the original deck card should be in hand")
	assert_true(battle.hand.has(in_discard_a), "the first reshuffled discard card should be in hand")
	assert_true(battle.hand.has(in_discard_b), "the second reshuffled discard card should be in hand")


func test_draw_stops_gracefully_when_deck_and_discard_are_both_exhausted() -> void:
	var battle: BattleState = _make_battle()
	var only: CardInstance = _new_card()
	battle.deck = [only] as Array[CardInstance]

	battle.draw(5)

	assert_eq(battle.hand, [only] as Array[CardInstance], "draw should pull every available card without erroring")
	assert_eq(battle.deck.size(), 0, "deck should be empty after exhausting available cards")
	assert_eq(battle.discard.size(), 0, "discard should remain empty when nothing was discarded")


func test_discard_hand_moves_every_remaining_hand_card_to_discard_in_order() -> void:
	var battle: BattleState = _make_battle()
	var first: CardInstance = _new_card()
	var second: CardInstance = _new_card()
	var third: CardInstance = _new_card()
	battle.hand = [first, second, third] as Array[CardInstance]

	battle.discard_hand()

	assert_eq(battle.hand.size(), 0, "hand should be empty after end-of-turn discard")
	assert_eq(battle.discard, [first, second, third] as Array[CardInstance], "all cards should land on discard preserving hand order")


func _watch_energy_changes(battle: BattleState) -> Array[BattleEvent]:
	var received: Array[BattleEvent] = []
	var listener: Callable = func(event: BattleEvent) -> void:
		received.append(event)
	var _sub: EventSubscription = battle.events.subscribe(EnergyChangedEvent, listener, 0)
	return received


func test_spend_energy_dispatches_an_energy_changed_event() -> void:
	var battle: BattleState = _make_battle()
	var observed: Array[BattleEvent] = _watch_energy_changes(battle)

	battle.spend_energy(1)

	assert_eq(observed.size(), 1, "spending energy should dispatch exactly one EnergyChangedEvent")


func test_refresh_energy_dispatches_an_energy_changed_event() -> void:
	var battle: BattleState = _make_battle()
	battle.spend_energy(2)
	var observed: Array[BattleEvent] = _watch_energy_changes(battle)

	battle.refresh_energy()

	assert_eq(observed.size(), 1, "refreshing energy should dispatch exactly one EnergyChangedEvent")


func _watch_hand_changes(battle: BattleState) -> Array[BattleEvent]:
	var received: Array[BattleEvent] = []
	var listener: Callable = func(event: BattleEvent) -> void:
		received.append(event)
	var _sub: EventSubscription = battle.events.subscribe(HandChangedEvent, listener, 0)
	return received


func test_move_top_of_deck_to_hand_dispatches_a_hand_changed_event() -> void:
	var battle: BattleState = _make_battle()
	battle.deck = [_new_card()] as Array[CardInstance]
	var observed: Array[BattleEvent] = _watch_hand_changes(battle)

	battle.move_top_of_deck_to_hand()

	assert_eq(observed.size(), 1, "drawing one card should dispatch exactly one HandChangedEvent")


func test_discard_from_hand_dispatches_a_hand_changed_event() -> void:
	var battle: BattleState = _make_battle()
	var card: CardInstance = _new_card()
	battle.hand = [card] as Array[CardInstance]
	var observed: Array[BattleEvent] = _watch_hand_changes(battle)

	battle.discard_from_hand(card)

	assert_eq(observed.size(), 1, "discarding from hand should dispatch a HandChangedEvent")


func test_exhaust_from_hand_dispatches_a_hand_changed_event() -> void:
	var battle: BattleState = _make_battle()
	var card: CardInstance = _new_card()
	battle.hand = [card] as Array[CardInstance]
	var observed: Array[BattleEvent] = _watch_hand_changes(battle)

	battle.exhaust_from_hand(card)

	assert_eq(observed.size(), 1, "exhausting from hand should dispatch a HandChangedEvent")


func test_battle_state_starts_with_three_energy_out_of_three() -> void:
	var battle: BattleState = _make_battle()

	var current: int = battle.energy_current
	var maximum: int = battle.energy_max
	assert_eq(current, 3, "energy_current should start at the 3-energy turn budget")
	assert_eq(maximum, 3, "energy_max should start at 3 (no carry-over budget)")


func test_spend_energy_subtracts_amount_from_energy_current() -> void:
	var battle: BattleState = _make_battle()

	battle.spend_energy(2)

	var current: int = battle.energy_current
	assert_eq(current, 1, "spending 2 of 3 energy should leave 1")


func test_refresh_energy_restores_energy_current_to_energy_max() -> void:
	var battle: BattleState = _make_battle()
	battle.spend_energy(3)

	battle.refresh_energy()

	var current: int = battle.energy_current
	var maximum: int = battle.energy_max
	assert_eq(current, maximum, "refresh should fill energy_current back to energy_max")


func test_discard_hand_dispatches_a_single_hand_changed_event_for_the_whole_batch() -> void:
	var battle: BattleState = _make_battle()
	battle.hand = [_new_card(), _new_card(), _new_card()] as Array[CardInstance]
	var observed: Array[BattleEvent] = _watch_hand_changes(battle)

	battle.discard_hand()

	assert_eq(observed.size(), 1, "discard_hand should dispatch exactly one HandChangedEvent for the batch")
