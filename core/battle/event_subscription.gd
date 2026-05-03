class_name EventSubscription
extends RefCounted


var is_active: bool = true


func release() -> void:
	is_active = false
