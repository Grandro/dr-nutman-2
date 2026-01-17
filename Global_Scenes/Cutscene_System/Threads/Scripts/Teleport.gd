extends CutsceneThreadBase
class_name CutsceneThreadTeleport

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var teleportation: StringName = cutscene_system_si.get_option_value(_a_args[&"Teleportation"])
	var destination: StringName = cutscene_system_si.get_option_value(_a_args[&"Destination"])
	var dest: Array[StringName] = [teleportation, destination]
	scene_manager_si.change_scene_dest(dest)
	_emit_completed()
	queue_free()
	
	super()
