extends DebugDialoguesAttributesTabBase
class_name DebugDialoguesAttributesTextTabObject

signal object_selected(p_key: StringName)

@onready var _a_Object: DebugObjectSelect = get_node("Margin/HSplit/Left/Object")
@onready var _a_Ensure_Visibility_Heading: Label = get_node("Margin/HSplit/Left/Ensure_Visibility/Heading")
@onready var _a_Ensure_Visibility: CheckBox = get_node("Margin/HSplit/Left/Ensure_Visibility/Value")

func _ready() -> void:
	_a_Object.selected.connect(_on_Object_selected)
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	var root_vp: Window = get_tree().get_root()
	_a_Object.set_viewport(root_vp)

func update_trans() -> void:
	_a_Ensure_Visibility_Heading.set_text(tr(&"DEBUG_DIALOGUES_ATTRIBUTES_ENSURE_VISIBILITY"))

func open(p_data: Dictionary) -> void:
	var key: StringName = p_data[&"Object"]
	_a_Object.select(key)
	
	var ensure_visibility: bool = p_data[&"Ensure_Visibility"]
	_a_Ensure_Visibility.set_pressed(ensure_visibility)

func open_init() -> void:
	_a_Ensure_Visibility.set_pressed(true)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Object"] = _a_Object.get_selected_key()
	data[&"Ensure_Visibility"] = _a_Ensure_Visibility.is_pressed()
	
	return data

func _on_Object_selected() -> void:
	var selected_key: StringName = _a_Object.get_selected_key()
	object_selected.emit(selected_key)

func _on_Scene_Manager_scene_changed(_p_instance: Node, _p_loaded_file_data: bool) -> void:
	_a_Object.update_options()
	_a_Object.add(&"$Custom", 0)
