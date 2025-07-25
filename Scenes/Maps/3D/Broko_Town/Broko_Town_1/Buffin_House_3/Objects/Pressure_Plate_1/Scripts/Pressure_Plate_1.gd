extends "res://Scenes/Object/Scripts/Node3D_Object.gd"

signal pushed()
signal released()

@onready var _a_Area = get_node("Area")
@onready var _a_States = get_node("States")
@onready var _a_Anims = get_node("Anims")

var _a_instances = []
var _a_locked = false

func _ready():
	super()
	_a_Area.body_entered.connect(_on_Area_body_entered)
	_a_Area.body_exited.connect(_on_Area_body_exited)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func _update_push():
	var state = _a_States.get_state()
	if _a_instances.size() >= 1 && state.begins_with("Release"):
		_a_States.set_state("Push")
		_a_Anims.update_anim()
		pushed.emit()

func _update_release():
	if _a_instances.size() == 0:
		_a_States.set_state("Release")
		_a_Anims.update_anim()
		released.emit()

func has_instance(p_instance):
	return _a_instances.has(p_instance)

func set_locked(p_locked):
	_a_locked = p_locked
	if p_locked:
		return
	
	var state = _a_States.get_state()
	match state:
		"Push": _update_release()
		"Pushed": _update_release()
		"Release": _update_push()
		"Released": _update_push()

func get_save_data():
	var data = super()
	data["Instances"] = []
	for instance in _a_instances:
		var path = instance.get_path()
		data["Instances"].push_back(path)
	data["Locked"] = _a_locked
	
	return data

func load_data(p_data):
	super(p_data)
	_a_instances.clear()
	for path in p_data["Instances"]:
		var instance = get_node(path)
		_a_instances.push_back(instance)
	set_locked(p_data["Locked"])

func _on_Area_body_entered(p_body):
	if !_a_instances.has(p_body):
		_a_instances.push_back(p_body)
	if !_a_locked:
		_update_push()

func _on_Area_body_exited(p_body):
	_a_instances.erase(p_body)
	if !_a_locked:
		_update_release()

func _on_Anims_anim_finished(p_name):
	match p_name:
		"Push": _a_States.set_state("Pushed")
		"Release": _a_States.set_state("Released")
