extends Node3D
class_name CompBalloonsBase

@export var _e_container_scene: PackedScene = null

@onready var _a_Origin: StaticBody3D = get_node("Origin")
@onready var _a_Containers: Node3D = get_node("Containers")
@onready var _a_Lines: MeshInstance3D = get_node("Lines")

var _a_entity: Node

var _a_containers: Dictionary[StringName, CompBalloonsContainerBase] = {} # Match key to instance

func _process(_p_delta: float) -> void:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.set_albedo(Color.WHITE)
	var immediate_mesh: ImmediateMesh = ImmediateMesh.new()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	for instance: CompBalloonsContainerBase in _a_containers.values():
		if !instance.is_visible():
			continue
		
		var from_pos: Vector3 = _a_Origin.get_position()
		var to_pos: Vector3 = to_local(instance.get_global_balloon_mark_position())
		immediate_mesh.surface_add_vertex(from_pos)
		immediate_mesh.surface_add_vertex(to_pos)
	immediate_mesh.surface_end()
	_a_Lines.set_mesh(immediate_mesh)

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-1]

func instantiate_container(p_key: StringName, p_modulate: Color) -> CompBalloonsContainerBase:
	var instance: CompBalloonsContainerBase = _e_container_scene.instantiate()
	var origin_path: NodePath = _a_Origin.get_path()
	instance.set_name(p_key)
	instance.set_manually_added(true)
	instance.set_joint_node_a.call_deferred(origin_path)
	instance.set_balloon_modulate.call_deferred(p_modulate)
	
	_a_containers[p_key] = instance
	_a_Containers.add_child(instance)
	
	set_process(true)
	
	return instance

func delete_container(p_key: StringName) -> void:
	var instance: CompBalloonsContainerBase = _a_containers[p_key]
	instance.queue_free()
	_a_containers.erase(p_key)
	
	if _a_containers.is_empty():
		set_process(false)
		_a_Lines.set_mesh(null)

func has_any_container() -> bool:
	return !_a_containers.is_empty()

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Containers"] = {}
	for key: StringName in _a_containers:
		var instance: CompBalloonsContainerBase = _a_containers[key]
		data[&"Containers"][key] = instance.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	for key: StringName in _a_containers:
		if !p_data[&"Containers"].has(key):
			delete_container(key)
	
	for key: StringName in p_data[&"Containers"]:
		var args: Dictionary = p_data[&"Containers"][key]
		var balloon_modulate: Color = args[&"Balloon_Modulate"]
		var manually_added: bool = args[&"Manually_Added"]
		if manually_added:
			instantiate_container(key, balloon_modulate)

func load_data_init() -> void:
	pass
