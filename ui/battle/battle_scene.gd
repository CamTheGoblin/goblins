extends Control


const STRIKE: CardData = preload("res://content/cards/strike.tres")

@onready var _controller: BattleController = $BattleController
@onready var _player_view: CharacterView = $Stage/PlayerView
@onready var _enemy_view: CharacterView = $Stage/EnemyView
@onready var _strike_button: Button = $DebugBar/StrikeButton

var _state: BattleState
var _enemy: Character


func _ready() -> void:
	var player: Character = Character.new(40)
	_enemy = Character.new(18)
	_state = BattleState.new(player, [_enemy] as Array[Character], _controller.events)
	_controller.state = _state

	_player_view.label_text = "Goblin (you)"
	_player_view.bind(player, _controller.events)
	_enemy_view.label_text = "Placeholder Enemy"
	_enemy_view.bind(_enemy, _controller.events)

	_strike_button.pressed.connect(_on_strike_pressed)
	_controller.run_battle.call()


func _on_strike_pressed() -> void:
	if _state == null:
		return
	if _enemy.current_hp <= 0:
		return
	var card: CardInstance = CardInstance.new(STRIKE)
	card.play(_state, _enemy)
