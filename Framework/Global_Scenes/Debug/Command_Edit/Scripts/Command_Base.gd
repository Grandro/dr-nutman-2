extends Control
class_name FWDebugCommandEditCommandBase

signal ok_pressed(p_data: Dictionary)

const _a_TITLE_LOC_ID: String = "FW_DEBUG_CUTSCENES_COMMANDS_%s"

@onready var _a_Window: FWWindowControlBase = get_node("Window")
@onready var _a_OK: Button
@onready var _a_Cancel: Button

func _ready() -> void:
	_a_Window.hidden.connect(_on_Window_hidden)
	_a_OK.pressed.connect(_on_OK_pressed)
	_a_Cancel.pressed.connect(_on_Cancel_pressed)
	
	var command: StringName = get_name()
	var loc_id: StringName = _a_TITLE_LOC_ID % command.to_upper()
	_a_Window.set_title(tr(loc_id))

func open(_p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	if p_data.is_empty():
		_open_init(p_res_data)
	else:
		_open_load(p_data, p_res_data)

func _open_init(_p_res_data: Dictionary) -> void:
	pass

func _open_load(_p_data: Dictionary, _p_res_data: Dictionary) -> void:
	pass

func close() -> void:
	queue_free()

func _get_save_data() -> Dictionary:
	return {}

func _on_Window_hidden() -> void:
	close()

func _on_OK_pressed() -> void:
	var data: Dictionary = _get_save_data()
	ok_pressed.emit(data)
	close()

func _on_Cancel_pressed() -> void:
	close()
