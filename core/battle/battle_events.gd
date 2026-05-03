class_name BattleEvents
extends Node


var _subscriptions: Array[Dictionary] = []


func subscribe(event_class: Script, listener: Callable, priority: int) -> EventSubscription:
	var handle: EventSubscription = EventSubscription.new()
	_subscriptions.append({
		"event_class": event_class,
		"listener": listener,
		"priority": priority,
		"handle": handle,
	})
	return handle


func dispatch(event: BattleEvent) -> BattleEvent:
	var ordered: Array[Dictionary] = _subscriptions.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa: int = a["priority"]
		var pb: int = b["priority"]
		return pa < pb)
	for entry: Dictionary in ordered:
		if event.cancelled:
			break
		var handle: EventSubscription = entry["handle"]
		if not handle.is_active:
			continue
		var event_class: Script = entry["event_class"]
		if not is_instance_of(event, event_class):
			continue
		var listener: Callable = entry["listener"]
		listener.call(event)
	return event
