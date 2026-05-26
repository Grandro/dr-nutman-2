extends CanvasLayer
class_name FWDebugCommandEdit

signal command_ok(p_data: Dictionary, p_command: StringName)

var _a_instance: FWDebugCommandEditCommandBase

func open(p_instance: FWDebugCommandEditorEntryBase, p_command: StringName, p_uid: String, p_data: Dictionary, p_res_data: Dictionary) -> void:
	var scene: PackedScene = load(p_uid)
	_a_instance = scene.instantiate()
	_a_instance.ok_pressed.connect(_on_command_ok_pressed.bind(p_command))
	_a_instance.open.call_deferred(p_instance, p_data, p_res_data)
	
	add_child(_a_instance)
	show()

func close() -> void:
	if is_instance_valid(_a_instance):
		_a_instance.close()
	hide()

func _on_command_ok_pressed(p_data: Dictionary, p_command: StringName) -> void:
	command_ok.emit(p_data, p_command)
