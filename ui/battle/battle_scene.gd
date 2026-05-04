extends Control


const STRIKE: CardData = preload("res://content/cards/strike.tres")
const DEFEND: CardData = preload("res://content/cards/defend.tres")

@onready var _controller: BattleController = $BattleController
@onready var _player_view: CharacterView = $Stage/PlayerView
@onready var _enemy_view: CharacterView = $Stage/EnemyView
@onready var _end_turn_button: Button = $EndTurnButton
@onready var _hand_ui: HandUI = $HandUI
@onready var _deck_count_label: Label = $DeckCount
@onready var _discard_count_label: Label = $DiscardCount
@onready var _energy_orb: EnergyOrb = $EnergyOrb

var _state: BattleState
var _enemy: Character
var _hand_subscription: EventSubscription


func _ready() -> void:
	var player: Character = Character.new(40)
	_enemy = Character.new(18)
	_state = BattleState.new(player, [_enemy] as Array[Character], _controller.events)
	_state.deck = _build_starter_deck()
	_controller.state = _state

	_player_view.label_text = "Goblin (you)"
	_player_view.bind(player, _controller.events)
	_enemy_view.label_text = "Placeholder Enemy"
	_enemy_view.bind(_enemy, _controller.events)

	_hand_ui.bind(_state, _player_view, [_enemy_view] as Array[CharacterView])
	_energy_orb.bind(_state)

	_hand_subscription = _controller.events.subscribe(HandChangedEvent, _on_hand_changed, 0)
	_end_turn_button.pressed.connect(_on_end_turn_pressed)

	_controller.run_battle.call()
	_hand_ui.render(_state.hand)
	_refresh_pile_counts()


func _exit_tree() -> void:
	if _hand_subscription != null:
		_hand_subscription.release()
		_hand_subscription = null
	if _controller != null and is_instance_valid(_controller):
		_controller.request_battle_end()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_SPACE:
			_on_end_turn_pressed()
			get_viewport().set_input_as_handled()


func _on_end_turn_pressed() -> void:
	if _controller == null:
		return
	_controller.request_end_turn()


func _on_hand_changed(_event: BattleEvent) -> void:
	_hand_ui.render.call_deferred(_state.hand)
	_refresh_pile_counts.call_deferred()


func _refresh_pile_counts() -> void:
	_deck_count_label.text = "Deck: %d" % _state.deck.size()
	_discard_count_label.text = "Discard: %d" % _state.discard.size()


func _build_starter_deck() -> Array[CardInstance]:
	var cards: Array[CardInstance] = []
	for i: int in 5:
		cards.append(CardInstance.new(STRIKE))
	for i: int in 5:
		cards.append(CardInstance.new(DEFEND))
	return cards
