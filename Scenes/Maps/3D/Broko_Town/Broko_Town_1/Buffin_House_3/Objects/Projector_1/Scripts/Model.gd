extends Node3D

signal ray_collided(p_collider, p_point, p_normal)

@onready var _a_Light = get_node("Light")
@onready var _a_Camera = get_node("Camera")
@onready var _a_Ray = get_node("Ray")

func _ready():
	set_process(false)
	_a_Light.hide()

func _process(_p_delta):
	if _a_Ray.is_colliding():
		var collider = _a_Ray.get_collider()
		var point = _a_Ray.get_collision_point()
		var normal = _a_Ray.get_collision_normal()
		ray_collided.emit(collider, point, normal)

func activate_ray(p_activate):
	_a_Ray.set_enabled(p_activate)
	set_process(p_activate)

func set_light_projector(p_projector):
	_a_Light.set_projector(p_projector)

func get_light_projector():
	return _a_Light.get_projector()

func set_light_visible(p_visible):
	_a_Light.set_visible(p_visible)

func get_camera():
	return _a_Camera

func get_save_data():
	var data = {}
	data["Transform"] = get_transform()
	data["Light_Visible"] = _a_Light.is_visible()
	data["Ray_Enabled"] = _a_Ray.is_enabled()
	
	return data

func load_data(p_data):
	set_transform(p_data["Transform"])
	_a_Light.set_visible(p_data["Light_Visible"])
	activate_ray(p_data["Ray_Enabled"])
