extends DebugValueSelectOptions
class_name DebugCommandEditCommandSetMoveRouteState

func update_options() -> void:
	var prev: Variant = get_selected_key()
	super()
	
	if has_key(prev):
		select(prev)
