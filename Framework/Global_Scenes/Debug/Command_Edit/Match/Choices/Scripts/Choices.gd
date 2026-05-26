extends FWDebugCommandEditMenuMatch
class_name FWDebugCommandEditCommandMatchChoices

var _a_Choice_Entry_Scene: PackedScene = preload("uid://c6uqookpbn4fh")

const _a_CHOICE_LOC_ID: String = "FW_DEBUG_%s"

@onready var _a_Key_Type: FWDebugValueSelectOptions = get_node("VBox/Key_Type")
@onready var _a_Chapter: FWDebugChapterSelect = get_node("VBox/Chapter")
@onready var _a_Location: FWDebugLocationSelect = get_node("VBox/Location")
@onready var _a_Dialogue: FWDebugCommandEditCommandMatchChoicesDialogue = get_node("VBox/Dialogue")
@onready var _a_Part: FWDebugCommandEditCommandMatchChoicesPart = get_node("VBox/Part")
@onready var _a_Choices_Heading: RichTextLabel = get_node("VBox/VBox/Heading")
@onready var _a_Choices: HBoxContainer = get_node("VBox/VBox/Choices")

func _ready() -> void:
	_a_Key_Type.selected.connect(_on_Key_Type_selected)
	_a_Chapter.selected.connect(_on_Chapter_selected)
	_a_Location.selected.connect(_on_Location_selected)
	_a_Dialogue.selected.connect(_on_Dialogue_selected)
	_a_Part.selected.connect(_on_Part_selected)
	
	_a_Key_Type.update_options()
	_a_Chapter.update_options()
	_a_Location.update_options()
	update_trans()

func update_trans() -> void:
	_a_Choices_Heading.set_text("[u][center]%s" % tr(&"CHOICES"))

func _update_choices() -> void:
	for child: FWDebugCommandEditCommandMatchChoicesChoiceEntry in _a_Choices.get_children():
		child.queue_free()
	
	_a_branches_values.clear()
	var dialogue_key: Variant = _a_Dialogue.get_selected_key()
	if dialogue_key == null:
		branches_values_changed.emit()
		return
	
	var key_type: StringName = _a_Key_Type.get_selected_key()
	var chapter: StringName = _a_Chapter.get_selected_key()
	var location: StringName = _a_Location.get_selected_key()
	var dialogues_data: Dictionary = Databases.get_global_map_data(&"Dialogues", key_type, chapter, location)
	var entry_key: StringName = StringName(_a_Part.get_selected_key())
	var args: Dictionary = dialogues_data[dialogue_key][&"Data"][entry_key]
	var type: StringName = args[&"Type"]
	match type:
		&"Text":
			var text_data: Dictionary = args[&"Data"][&"Text"]
			var choice_entries: Dictionary = text_data[&"Choice"][&"Entries"]
			var choice_entries_keys: Array[StringName]; choice_entries_keys.assign(choice_entries.keys())
			for i: int in choice_entries_keys.size():
				var choice_entry_key: StringName = choice_entries_keys[i]
				var choice_args: Dictionary = choice_entries[choice_entry_key]
				var heading: String = str(i)
				var text: String = tr(choice_args[&"Loc_ID"][&"Loc_ID"])
				var value: Variant = choice_args[&"Value"]
				var str_value: String = str(value)
				var instance: FWDebugCommandEditCommandMatchChoicesChoiceEntry = _a_Choice_Entry_Scene.instantiate()
				instance.set_heading.call_deferred(heading)
				instance.set_text.call_deferred(text)
				instance.set_value.call_deferred(str_value)
				
				if !_a_branches_values.has(value):
					_a_branches_values.push_back(value)
				_a_Choices.add_child(instance)
		
		&"Choice":
			pass
	
	branches_values_changed.emit()

func _selected_key_type_changed(p_update: bool) -> void:
	var key_type: StringName = _a_Key_Type.get_selected_key()
	_a_Chapter.set_visible(key_type == &"Map")
	_a_Location.set_visible(key_type == &"Map")
	_a_Dialogue.set_key_type(key_type)
	_a_Part.set_key_type(key_type)
	
	if p_update:
		_a_Dialogue.update_options()
		_selected_dialogue_changed()

func _selected_chapter_changed(p_update: bool) -> void:
	var chapter: StringName = _a_Chapter.get_selected_key()
	_a_Dialogue.set_chapter(chapter)
	_a_Part.set_chapter(chapter)
	
	if p_update:
		_a_Dialogue.update_options()
		_selected_dialogue_changed()

func _selected_location_changed() -> void:
	var location: StringName = _a_Location.get_selected_key()
	_a_Dialogue.set_location(location)
	_a_Part.set_location(location)
	
	_a_Dialogue.update_options()
	_selected_dialogue_changed()

func _selected_dialogue_changed() -> void:
	var dialogue_key: Variant = _a_Dialogue.get_selected_key()
	if dialogue_key == null:
		dialogue_key = &""
	
	_a_Part.set_dialogue_key(dialogue_key)
	_a_Part.update_options()
	_update_choices()

func _selected_part_changed() -> void:
	_update_choices()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Key_Type"] = _a_Key_Type.get_save_data()
	data[&"Chapter"] = _a_Chapter.get_save_data()
	data[&"Location"] = _a_Location.get_save_data()
	data[&"Dialogue"] = _a_Dialogue.get_save_data()
	data[&"Part"] = _a_Part.get_save_data()
	
	return data

func _load_data_init() -> void:
	_a_Key_Type.load_data_init()
	_selected_key_type_changed(false)
	_a_Chapter.load_data_init()
	_selected_chapter_changed(false)
	_a_Location.load_data_init()
	_selected_location_changed()
	_a_Dialogue.load_data_init()
	_selected_dialogue_changed()
	_a_Part.load_data_init()

func _load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Key_Type.load_data(p_data[&"Key_Type"])
	_selected_key_type_changed(false)
	_a_Chapter.load_data(p_data[&"Chapter"])
	_selected_chapter_changed(false)
	_a_Location.load_data(p_data[&"Location"])
	_selected_location_changed()
	_a_Dialogue.load_data(p_data[&"Dialogue"])
	_selected_dialogue_changed()
	_a_Part.load_data(p_data[&"Part"])

func _on_Key_Type_selected() -> void:
	_selected_key_type_changed(true)

func _on_Chapter_selected() -> void:
	_selected_chapter_changed(true)

func _on_Location_selected() -> void:
	_selected_location_changed()

func _on_Dialogue_selected() -> void:
	_selected_dialogue_changed()

func _on_Part_selected() -> void:
	_selected_part_changed()
