extends TabContainer
class_name DebugDialoguesAttributeBase

func open(p_data: Dictionary) -> void:
	for child: DebugDialoguesAttributesTabBase in get_children():
		if p_data.is_empty():
			child.open_init()
		else:
			var key: StringName = child.get_key()
			child.open(p_data[key])
	
	show()

func close() -> void:
	hide()

func set_tabs_keys_type(p_keys_type: StringName) -> void:
	for child: DebugDialoguesAttributesTabBase in get_children():
		child.set_keys_type(p_keys_type)

func _set_tab_hidden(p_instance: DebugDialoguesAttributesTabBase, p_hidden: bool) -> void:
	var idx: int = p_instance.get_index()
	set_tab_hidden(idx, p_hidden)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	for child: DebugDialoguesAttributesTabBase in get_children():
		var key: StringName = child.get_key()
		data[key] = child.get_save_data()
	
	return data
