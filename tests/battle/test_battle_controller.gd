extends GutTest


func _make_controller_with_battle() -> BattleController:
	var controller: BattleController = BattleController.new()
	add_child_autofree(controller)
	var player: Character = Character.new(40)
	var enemy: Character = Character.new(18)
	controller.state = BattleState.new(player, [enemy] as Array[Character], controller.events)
	return controller


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


func test_request_end_resumes_run_battle_and_dispatches_battle_ended() -> void:
	var controller: BattleController = _make_controller_with_battle()

	var ended: Array[int] = []
	var on_end: Callable = func(_e: BattleEvent) -> void:
		ended.append(1)
	var _sub: EventSubscription = controller.events.subscribe(BattleEndedEvent, on_end, 0)

	controller.run_battle.call()
	controller.request_end()
	await wait_physics_frames(1)

	assert_eq(ended.size(), 1, "battle_ended should be dispatched once the controller is told to end")
