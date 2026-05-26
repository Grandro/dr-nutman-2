extends FWDebugKeysEditorParts
class_name FWDebugStater

@onready var _a_Attributes: FWDebugStaterAttributes = get_node("VBox/HBox/VBox/Panel/Scroll/Attributes")

func _ready() -> void:
	super()
	_a_Parts.entry_type_changed.connect(_on_Parts_entry_type_changed)
	_a_Parts.entry_type_changing.connect(_on_Parts_entry_type_changing)

func _open() -> void:
	super()
	var key: StringName = _a_key_entry.get_key()
	_a_Attributes.set_key(key)

func _close() -> void:
	super()
	_close_attributes()

func _open_attributes() -> void:
	var data: Dictionary = _a_part.get_data()
	var type: StringName = _a_part.get_type()
	_a_Attributes.open(data[type])

func _close_attributes() -> void:
	_a_Attributes.close()

func _update_part_data() -> void:
	# Update data of a_part_instance
	if !is_instance_valid(_a_part):
		return
	
	var type: StringName = _a_part.get_type()
	var data: Dictionary = _a_Attributes.get_save_data()
	_a_part.set_data_type(type, data)

func _selected_part_changed(p_instance: FWDebugEntryListEntry) -> void:
	if is_instance_valid(_a_part):
		_close_attributes()
	super(p_instance)
	
	_open_attributes()

func _on_Dialogues_key_changed(p_old: StringName, p_new: StringName) -> void:
	var data: Dictionary = _get_data()
	for state_key: StringName in data:
		var state_data: Dictionary = data[state_key][&"Data"]
		for state_entry_key: StringName in state_data:
			var state_args: Dictionary = state_data[state_entry_key]
			for state_type: StringName in state_args[&"Data"]:
				var state_type_args: Dictionary = state_args[&"Data"][state_type]
				if state_type_args.is_empty():
					continue
				
				var actions_data: Dictionary = state_type_args[&"Actions"]
				for action_entry_key: StringName in actions_data:
					var action_args: Dictionary = actions_data[action_entry_key]
					for entry_args: Dictionary in action_args[&"Editor"]:
						Debug.fix_data_dialogue_key(entry_args, p_old, p_new)

func _on_Dialogues_part_moved(p_old_idx: int, p_new_idx: int, p_shift_others: bool) -> void:
	var idx_shifts: Dictionary[int, int] = {}
	idx_shifts[p_old_idx] = p_new_idx
	if p_shift_others:
		if p_old_idx < p_new_idx:
			for idx: int in range(p_old_idx + 1, p_new_idx + 1):
				idx_shifts[idx] = idx - 1
		else:
			for idx: int in range(p_new_idx, p_old_idx):
				idx_shifts[idx] = idx + 1
	
	var data: Dictionary = _get_data()
	for state_key: StringName in data:
		var state_data: Dictionary = data[state_key][&"Data"]
		for state_entry_key: StringName in state_data:
			var state_args: Dictionary = state_data[state_entry_key]
			for state_type: StringName in state_args[&"Data"]:
				var state_type_args: Dictionary = state_args[&"Data"][state_type]
				if state_type_args.is_empty():
					continue
				
				var actions_data: Dictionary = state_type_args[&"Actions"]
				for action_entry_key: StringName in actions_data:
					var action_args: Dictionary = actions_data[action_entry_key]
					for entry_args: Dictionary in action_args[&"Editor"]:
						Debug.fix_data_dialogue_part_idx(entry_args, idx_shifts)

func _on_visibility_changed() -> void:
	super()
	_a_Attributes.action_set_editor_active(visible)

func _on_Parts_entry_type_changed(p_instance: FWDebugEntryListTypeEntry) -> void:
	if _a_part != p_instance:
		return
	
	_close_attributes()
	_open_attributes()

func _on_Parts_entry_type_changing() -> void:
	_update_part_data()
