extends GutTest


class FakeDamageEvent:
	extends BattleEvent
	var amount: int = 0


class TurnEndedEvent:
	extends BattleEvent


func test_dispatch_invokes_subscribed_listener_with_the_event() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var received: Array[BattleEvent] = []
	var listener: Callable = func(event: BattleEvent) -> void:
		received.append(event)

	var _sub: EventSubscription = bus.subscribe(BattleEvent, listener, 0)

	var dispatched: BattleEvent = BattleEvent.new()
	bus.dispatch(dispatched)

	assert_eq(received.size(), 1, "listener should fire exactly once per dispatch")
	assert_same(received[0], dispatched, "listener should receive the dispatched event instance")


func test_subscribers_run_in_ascending_priority_regardless_of_registration_order() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var call_order: Array[String] = []
	var high_listener: Callable = func(_event: BattleEvent) -> void:
		call_order.append("high")
	var low_listener: Callable = func(_event: BattleEvent) -> void:
		call_order.append("low")
	var mid_listener: Callable = func(_event: BattleEvent) -> void:
		call_order.append("mid")

	var _high: EventSubscription = bus.subscribe(BattleEvent, high_listener, 100)
	var _low: EventSubscription = bus.subscribe(BattleEvent, low_listener, 1)
	var _mid: EventSubscription = bus.subscribe(BattleEvent, mid_listener, 50)

	bus.dispatch(BattleEvent.new())

	assert_eq(call_order, ["low", "mid", "high"] as Array[String], "subscribers should run lowest priority first")


func test_earlier_subscriber_mutations_are_visible_to_later_subscribers() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var observed: Array[int] = []
	var doubler: Callable = func(event: BattleEvent) -> void:
		var dmg: FakeDamageEvent = event
		dmg.amount *= 2
	var observer: Callable = func(event: BattleEvent) -> void:
		var dmg: FakeDamageEvent = event
		observed.append(dmg.amount)

	var _doubler: EventSubscription = bus.subscribe(FakeDamageEvent, doubler, 1)
	var _observer: EventSubscription = bus.subscribe(FakeDamageEvent, observer, 2)

	var event: FakeDamageEvent = FakeDamageEvent.new()
	event.amount = 5
	bus.dispatch(event)

	assert_eq(observed, [10] as Array[int], "later subscriber should see amount mutated by earlier subscriber")


func test_setting_cancelled_short_circuits_remaining_subscribers() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var ran: Array[String] = []
	var first: Callable = func(_e: BattleEvent) -> void:
		ran.append("first")
	var canceller: Callable = func(e: BattleEvent) -> void:
		ran.append("canceller")
		e.cancelled = true
	var should_not_run: Callable = func(_e: BattleEvent) -> void:
		ran.append("should_not_run")

	var _a: EventSubscription = bus.subscribe(BattleEvent, first, 1)
	var _b: EventSubscription = bus.subscribe(BattleEvent, canceller, 2)
	var _c: EventSubscription = bus.subscribe(BattleEvent, should_not_run, 3)

	bus.dispatch(BattleEvent.new())

	assert_eq(ran, ["first", "canceller"] as Array[String], "subscribers after a cancelling subscriber should not run")


func test_released_subscription_does_not_fire_on_subsequent_dispatch() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var hits: Array[int] = []
	var listener: Callable = func(_e: BattleEvent) -> void:
		hits.append(1)

	var sub: EventSubscription = bus.subscribe(BattleEvent, listener, 0)

	bus.dispatch(BattleEvent.new())
	assert_eq(hits.size(), 1, "listener should fire on first dispatch")

	sub.release()
	bus.dispatch(BattleEvent.new())
	assert_eq(hits.size(), 1, "listener should not fire after its handle was released")


func test_releasing_a_group_of_handles_detaches_all_listeners() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var hits: Array[String] = []
	var a_listener: Callable = func(_e: BattleEvent) -> void:
		hits.append("a")
	var b_listener: Callable = func(_e: BattleEvent) -> void:
		hits.append("b")

	var group: Array[EventSubscription] = [
		bus.subscribe(BattleEvent, a_listener, 1),
		bus.subscribe(BattleEvent, b_listener, 2),
	]

	bus.dispatch(BattleEvent.new())
	assert_eq(hits, ["a", "b"] as Array[String], "both listeners fire before release")

	for handle: EventSubscription in group:
		handle.release()

	bus.dispatch(BattleEvent.new())
	assert_eq(hits, ["a", "b"] as Array[String], "no listeners fire after group release")


func test_subscriber_only_fires_for_its_registered_event_class() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var damage_hits: Array[int] = []
	var turn_ended_hits: Array[int] = []
	var damage_listener: Callable = func(_e: BattleEvent) -> void:
		damage_hits.append(1)
	var turn_ended_listener: Callable = func(_e: BattleEvent) -> void:
		turn_ended_hits.append(1)

	var _d: EventSubscription = bus.subscribe(FakeDamageEvent, damage_listener, 0)
	var _t: EventSubscription = bus.subscribe(TurnEndedEvent, turn_ended_listener, 0)

	bus.dispatch(FakeDamageEvent.new())
	bus.dispatch(TurnEndedEvent.new())

	assert_eq(damage_hits.size(), 1, "FakeDamageEvent subscriber should fire only for FakeDamageEvent dispatches")
	assert_eq(turn_ended_hits.size(), 1, "TurnEndedEvent subscriber should fire only for TurnEndedEvent dispatches")


func test_non_mutating_subscribers_observe_the_same_payload_as_a_pure_notification_fanout() -> void:
	var bus: BattleEvents = BattleEvents.new()
	add_child_autofree(bus)

	var observed_a: Array[int] = []
	var observed_b: Array[int] = []
	var observer_a: Callable = func(e: BattleEvent) -> void:
		var dmg: FakeDamageEvent = e
		observed_a.append(dmg.amount)
	var observer_b: Callable = func(e: BattleEvent) -> void:
		var dmg: FakeDamageEvent = e
		observed_b.append(dmg.amount)

	var _a: EventSubscription = bus.subscribe(FakeDamageEvent, observer_a, 1)
	var _b: EventSubscription = bus.subscribe(FakeDamageEvent, observer_b, 2)

	var event: FakeDamageEvent = FakeDamageEvent.new()
	event.amount = 7
	bus.dispatch(event)

	assert_eq(observed_a, [7] as Array[int], "first observer sees the payload via the same dispatch as a notification fanout")
	assert_eq(observed_b, [7] as Array[int], "second observer sees the same unmutated payload via the same dispatch path")
