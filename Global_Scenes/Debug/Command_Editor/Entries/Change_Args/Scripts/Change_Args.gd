extends DebugCommandEditorEntryObject
class_name DebugCommandEditorEntryChangeArgs

@export var _e_loc_id: StringName = &""

# Breakable: [&"Object"][&"Value"], [&"Idx"][&"Value"]
func _update_warnings_add() -> void:
	var instance: Node = _update_warnings_add_object()
	if is_instance_valid(instance):
		var interactions_comp: Node = instance.comph().get_comp("Interactions")
		var interaction_count: int = interactions_comp.get_child_count()
		var idx: int = _a_data[&"Idx"][&"Value"]
		if idx >= interaction_count:
			var value_keys: Array = [&"Idx", &"Value"]
			var args: WarningArgsInt = WarningArgsInt.new(idx, value_keys, 0, interaction_count - 1)
			_a_warnings.push_back(args)

func _update_display_main_base_desc() -> void:
	_a_Main.set_base_desc("%s:" % tr(_e_loc_id))

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var type_text: String = _get_display_text(_a_data[&"Type"])
	var idx_text: String = _get_display_text(_a_data[&"Idx"])
	
	var text: String = object_text
	text += ", %s" % type_text
	text += ", %s" % idx_text
	_a_Main.set_base_args(text)

func _update_display_main_args() -> void:
	super()
	
	var value: Array = _a_data[&"Value"][&"Value"]
	for args in value:
		_instantiate_main_arg(str(args), _e_color)
