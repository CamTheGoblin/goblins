class_name BattleState
extends RefCounted


const HAND_SIZE_CAP: int = 10

var player: Character
var enemies: Array[Character]
var events: BattleEvents

var deck: Array[CardInstance] = []
var hand: Array[CardInstance] = []
var discard: Array[CardInstance] = []
var exhaust: Array[CardInstance] = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(starting_player: Character, starting_enemies: Array[Character], event_bus: BattleEvents) -> void:
	player = starting_player
	enemies = starting_enemies
	events = event_bus


func move_top_of_deck_to_hand() -> CardInstance:
	var card: CardInstance = deck.pop_front()
	hand.append(card)
	_notify_hand_changed()
	return card


func discard_from_hand(card: CardInstance) -> void:
	hand.erase(card)
	discard.append(card)
	_notify_hand_changed()


func exhaust_from_hand(card: CardInstance) -> void:
	hand.erase(card)
	exhaust.append(card)
	_notify_hand_changed()


func discard_hand() -> void:
	discard.append_array(hand)
	hand.clear()
	_notify_hand_changed()


func _notify_hand_changed() -> void:
	events.dispatch(HandChangedEvent.new())


func draw(count: int) -> void:
	for i: int in count:
		if hand.size() >= HAND_SIZE_CAP:
			return
		if deck.is_empty():
			reshuffle_discard_into_deck()
		if deck.is_empty():
			return
		move_top_of_deck_to_hand()


func reshuffle_discard_into_deck() -> void:
	deck.append_array(discard)
	discard.clear()
	for i: int in range(deck.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap: CardInstance = deck[i]
		deck[i] = deck[j]
		deck[j] = swap
