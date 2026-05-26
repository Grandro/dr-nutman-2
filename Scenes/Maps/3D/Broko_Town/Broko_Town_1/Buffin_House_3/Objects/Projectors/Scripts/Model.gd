extends Node3D
class_name ObjectProjectorModel

signal ray_collided(p_collider: Object, p_point: Vector3, p_normal: Vector3)
signal light_visibility_changed()

@onready var _a_Light: SpotLight3D = get_node("Light")
@onready var _a_Camera: FWCompCamera3D = get_node("Camera")
@onready var _a_Ray: RayCast3D = get_node("Ray")
@onready var _a_Audio_Switch: AudioStreamPlayer3D = get_node("Audio_Switch")

func _process(_p_delta: float) -> void:
	if _a_Ray.is_colliding():
		var collider: Object = _a_Ray.get_collider()
		var point: Vector3 = _a_Ray.get_collision_point()
		var normal: Vector3 = _a_Ray.get_collision_normal()
		ray_collided.emit(collider, point, normal)

func activate_ray(p_activate: bool) -> void:
	_a_Ray.set_enabled(p_activate)
	set_process(p_activate)

func set_light_projector(p_projector: ImageTexture) -> void:
	_a_Light.set_projector(p_projector)

func get_light_projector() -> ImageTexture:
	return _a_Light.get_projector()

func set_light_visible(p_visible: bool) -> void:
	_a_Audio_Switch.play()
	_a_Light.set_visible(p_visible)
	
	light_visibility_changed.emit()

func get_camera() -> FWCompCamera3D:
	return _a_Camera

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Transform"] = get_transform()
	data[&"Light_Visible"] = _a_Light.is_visible()
	data[&"Ray_Enabled"] = _a_Ray.is_enabled()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_transform(p_data[&"Transform"])
	_a_Light.set_visible(p_data[&"Light_Visible"])
	activate_ray(p_data[&"Ray_Enabled"])

func load_data_init() -> void:
	set_process(false)
	_a_Light.hide()
