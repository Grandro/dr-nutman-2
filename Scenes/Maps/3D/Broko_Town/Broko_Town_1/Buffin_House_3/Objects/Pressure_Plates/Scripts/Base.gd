extends FWNode3DObject
class_name ObjectPressurePlateBase

signal pushed()
signal released()

@onready var _a_Area: Area3D = get_node("Area")
@onready var _a_States: FWCompStates = get_node("States")
@onready var _a_Anims: FWCompAnims = get_node("Anims")

var _a_instances: Array[Node] = []
var _a_locked: bool = false

func _ready() -> void:
	super()
	_a_Area.body_entered.connect(_on_Area_body_entered)
	_a_Area.body_exited.connect(_on_Area_body_exited)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func _update_push() -> void:
	var state: StringName = _a_States.get_state()
	if _a_instances.size() >= 1 && state.begins_with(&"Release"):
		set_state(&"Push")

func _update_release() -> void:
	if _a_instances.size() == 0:
		set_state(&"Release")

func has_instance(p_instance: Node) -> bool:
	return _a_instances.has(p_instance)

func set_locked(p_locked: bool) -> void:
	_a_locked = p_locked
	if p_locked:
		return
	
	var state: StringName = _a_States.get_state()
	match state:
		&"Push": _update_release()
		&"Pushed": _update_release()
		&"Release": _update_push()
		&"Released": _update_push()

func set_state(p_state: StringName) -> void:
	_a_States.set_state(p_state)
	_a_Anims.update_anim()
	
	if p_state.begins_with("Push"):
		pushed.emit()
	elif p_state.begins_with("Release"):
		released.emit()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	
	var instances_data: Array[NodePath] = []
	var size: int = _a_instances.size()
	instances_data.resize(size)
	for i: int in size:
		var instance: Node = _a_instances[i]
		var path: NodePath = instance.get_path()
		instances_data[i] = path
	data[&"Instances"] = instances_data
	data[&"Locked"] = _a_locked
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	var instances_data: Array[NodePath] = p_data[&"Instances"]
	var size: int = instances_data.size()
	_a_instances.resize(size)
	for i: int in size:
		var path: NodePath = instances_data[i]
		var instance: Node = get_node(path)
		_a_instances[i] = instance
	set_locked(p_data[&"Locked"])

func _on_Area_body_entered(p_body: Node) -> void:
	if !_a_instances.has(p_body):
		_a_instances.push_back(p_body)
	if !_a_locked:
		_update_push()

func _on_Area_body_exited(p_body: Node) -> void:
	_a_instances.erase(p_body)
	if !_a_locked:
		_update_release()

func _on_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Push": _a_States.set_state(&"Pushed")
		&"Release": _a_States.set_state(&"Released")
