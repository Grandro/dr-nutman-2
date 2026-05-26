extends Node
class_name FWDebugTeleportMap

@export var _e_free_cameras: Dictionary[StringName, PackedScene] = {} # Match dim to scene

const _a_DIMENSIONS_PATH: String = "res://Framework/Global_Scenes/Debug/Teleport_Map/Dimensions/%s.gd"

var _a_Select_Point: Texture2D = preload("uid://3q4k620n7bgm")

var _a_free_camera: Node
var _a_dimensions: FWExtensionBase

func _ready() -> void:
	set_physics_process(false)
	set_process_input(false)

func _physics_process(p_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector(&"Move_Left", &"Move_Right", &"Move_Up", &"Move_Down")
	var relative: Vector2 = input_dir * p_delta
	_a_dimensions.handle_free_camera_pan(relative)

func _input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Mouse_Left"):
		var global_pos: Variant = _a_dimensions.get_global_mouse_pos()
		if global_pos:
			var player: Node = Global.get_object(&"Player")
			player.set_global_position(global_pos)
			_close()
	
	if p_event.is_action_pressed(&"Mouse_Right"):
		_close()

func open() -> void:
	_a_free_camera = _instantiate_free_camera()
	_a_dimensions = _instantiate_dimensions()
	add_child(_a_free_camera)
	
	var player: Node = Global.get_object(&"Player")
	var global_pos: Variant = player.get_global_position()
	_a_free_camera.set_global_position(global_pos)
	_a_free_camera.comph().call_comp("Camera", &"make_current_")
	Input.set_custom_mouse_cursor(_a_Select_Point, Input.CURSOR_ARROW, Vector2(12, 12))
	
	set_physics_process(true)
	set_process_input(true)
	get_tree().get_root().grab_focus()

func _close() -> void:
	_a_free_camera.queue_free()
	_a_dimensions.free()
	
	var camera: Node = Global.get_curr_camera()
	var default_cursor: Texture2D = Global.get_default_cursor()
	camera.make_current_()
	Input.set_custom_mouse_cursor(default_cursor)
	
	set_physics_process(false)
	set_process_input(false)
	Debug.grab_window_focus()

func _instantiate_free_camera() -> Node:
	var dim: StringName = Scene_Manager.get_curr_scene_dim()
	var scene: PackedScene = _e_free_cameras[dim]
	var instance: Node = scene.instantiate()
	
	return instance

func _instantiate_dimensions() -> FWExtensionBase:
	var dim: StringName = Scene_Manager.get_curr_scene_dim()
	var script: GDScript = load(_a_DIMENSIONS_PATH % dim)
	var instance: FWExtensionBase = script.new(self)
	
	return instance

func get_free_camera_instance() -> Node:
	return _a_free_camera
