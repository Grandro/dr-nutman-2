extends SubViewportContainer
class_name FWDebugPreview

@export var _e_singletons: Array[String] = ["Global", "FPS_Display", "Scene_Manager",
											"Audio_Manager", "Dialogue_System",
											"Cutscene_System", "Progress", "Messages"]

var _a_VP_Scene: PackedScene = preload("uid://327misx7wcjf")

var _a_preview_scene: Node = null
var _a_vp: FWVP = null

func open() -> void:
	var curr_scene: PackedScene = Scene_Manager.get_curr_scene()
	_a_preview_scene = curr_scene.instantiate()
	_a_vp = _a_VP_Scene.instantiate()
	_make_free_camera_current.call_deferred()
	
	var root: Window = get_tree().get_root()
	for si_name: String in _e_singletons:
		var child: Node = root.get_node(si_name)
		var scene: PackedScene = load(child.get_scene_file_path())
		var instance: Node = scene.instantiate()
		instance.set_process_mode(PROCESS_MODE_ALWAYS)
		
		_a_vp.add_child(instance)
	
	_a_vp.add_child(_a_preview_scene)
	add_child(_a_vp)
	
	for si_name: String in _e_singletons:
		var root_child: Node = root.get_node(si_name)
		var vp_child: Node = _a_vp.get_node(si_name)
		_copy_singleton_vars(si_name, root_child, vp_child)
	
	var instances: Array[Node] = Global.get_objects_vp(_a_vp, ["Operate"])
	for instance: Node in instances:
		instance.comph().call_comp("Operate", &"disable")
	PhysicsServer3D.set_active(true)

func close() -> void:
	if _a_vp != null:
		_a_vp.queue_free()
	_a_preview_scene = null
	_a_vp = null

func _make_free_camera_current() -> void:
	var global_si: Global = Global.get_singleton(_a_preview_scene, "Global")
	var free_camera: Node = _a_preview_scene.get_free_camera()
	var camera_comp: Node = free_camera.comph().get_comp("Camera")
	global_si.set_curr_camera(camera_comp)

func _copy_singleton_vars(p_si_name: StringName, p_org: Node, p_dup: Node) -> void:
	match p_si_name:
		&"Global":
			p_dup.set_play_time(p_org.get_play_time())
			p_dup.set_camera_limit(p_org.get_camera_limit().duplicate())
			p_dup.set_party_members(p_org.get_party_members().duplicate(true))
			p_dup.set_inventory(p_org.get_inventory().duplicate(true))
		
		&"FPS_Display":
			p_dup.set_pos(p_org.get_pos())
		
		&"Progress":
			p_dup.set_chapter(p_org.get_chapter())
			p_dup.set_dialogue_choices(p_org.get_dialogue_choices().duplicate(true))

func get_preview_scene() -> Node:
	return _a_preview_scene

func set_VP_size_2d_override(p_size_2d_override: Vector2i) -> void:
	_a_vp.set_size_2d_override(p_size_2d_override)

func get_VP() -> FWVP:
	return _a_vp
