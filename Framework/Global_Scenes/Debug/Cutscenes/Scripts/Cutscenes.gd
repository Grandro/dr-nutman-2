extends FWDebugKeysEditorParts
class_name FWDebugCutscenes

@onready var _a_Editor: FWDebugCommandEditor = get_node("VBox/HBox/VBox/Editor")
@onready var _a_Preview: FWDebugCommandsPreview = get_node("Preview")

func _ready() -> void:
	super()
	_a_Editor.option_test_selected.connect(_on_Editor_option_test_selected)

func _open_preview(p_skip_idxs: Array[int] = []) -> void:
	var cutscene_data: Array[Dictionary] = _a_Editor.get_cutscene_data()
	_a_Preview.open(cutscene_data, p_skip_idxs)

func _update_part_data() -> void:
	# Update data of a_part_instance
	if !is_instance_valid(_a_part):
		return
	
	var type: StringName = _a_part.get_type()
	var save_data: Array[Dictionary] = _a_Editor.get_save_data()
	_a_part.set_data_type(type, save_data)

func _selected_part_changed(p_instance: FWDebugEntryListEntry) -> void:
	super(p_instance)
	
	var part_data: Dictionary = _a_part.get_data()
	var part_type: StringName = _a_part.get_type()
	var data: Array[Dictionary]; data.assign(part_data[part_type])
	_a_Editor.update_entries(data)

func _on_Parts_Add_Select_pressed() -> void:
	_a_Parts.instantiate_part_entry(&"Default")

func _on_Options_Preview_pressed() -> void:
	super()
	
	var skip_idxs: Array[int] = _a_Editor.get_skip_idxs()
	_open_preview(skip_idxs)

func _on_visibility_changed() -> void:
	super()
	_a_Editor.set_active(visible)

func _on_Editor_option_test_selected(p_instance: FWDebugCommandEditorEntryBase) -> void:
	var skip_idxs: Array[int] = _a_Editor.get_skip_idxs(p_instance)
	_open_preview(skip_idxs)

func _on_Dialogues_key_changed(p_old: StringName, p_new: StringName) -> void:
	var data: Dictionary = _get_data()
	for cutscene_key: StringName in data:
		var cutscene_data: Dictionary = data[cutscene_key][&"Data"]
		for cutscene_entry_key: StringName in cutscene_data:
			var cutscene_args: Dictionary = cutscene_data[cutscene_entry_key]
			for entry_args: Dictionary in cutscene_args[&"Data"][&"Default"]:
				Debug.fix_data_dialogue_key(entry_args, p_old, p_new)

func _on_Dialogues_part_moved(p_old_idx: int, p_new_idx: int, p_shift_others: bool) -> void:
	var idx_shifts: Dictionary[int, int] = {}
	idx_shifts[p_old_idx] = p_new_idx
	if p_shift_others:
		if p_old_idx < p_new_idx:
			for idx in range(p_old_idx + 1, p_new_idx + 1):
				idx_shifts[idx] = idx - 1
		else:
			for idx in range(p_new_idx, p_old_idx):
				idx_shifts[idx] = idx + 1
	
	var data: Dictionary = _get_data()
	for cutscene_key: StringName in data:
		var cutscene_data: Dictionary = data[cutscene_key][&"Data"]
		for cutscene_entry_key: StringName in cutscene_data:
			var cutscene_args: Dictionary = cutscene_data[cutscene_entry_key]
			for entry_args: Dictionary in cutscene_args[&"Data"][&"Default"]:
				Debug.fix_data_dialogue_part_idx(entry_args, idx_shifts)
