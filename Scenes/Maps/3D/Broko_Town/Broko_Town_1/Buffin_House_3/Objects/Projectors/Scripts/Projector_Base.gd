extends FWNode3DObject
class_name ObjectProjectorBase

signal model_ray_collided(p_collider: Object, p_pos: Vector3)
signal power_changed(p_power: bool)

@onready var _a_Model: ObjectProjectorModel = get_node("Model")
@onready var _a_Interactions: FWCompInteractions3D = get_node("Interactions")
@onready var _a_VP: SubViewport = get_node("VP")
@onready var _a_Rotate_Menu: ObjectProjectorRotateMenu = get_node("Rotate_Menu")

var _a_projector_texture: ImageTexture
var _a_can_power_on: bool = true
var _a_power: bool = false

func _ready() -> void:
	super()
	_a_Model.ray_collided.connect(_on_Model_ray_collided)
	_a_Interactions.interacted_empty.connect(_on_Interactions_interacted_empty)
	
	_a_Rotate_Menu.set_projector(self)
	_a_Rotate_Menu.set_model(_a_Model)
	
	await RenderingServer.frame_post_draw
	var vp_image: Image = _a_VP.get_texture().get_image()
	_a_projector_texture = ImageTexture.create_from_image(vp_image)
	_a_Model.set_light_projector(_a_projector_texture)

func open_rotate_menu() -> void:
	_a_Rotate_Menu.open()

func try_close_rotate_menu() -> void:
	if _a_Rotate_Menu.is_open():
		_a_Rotate_Menu.close()

func set_power(p_power: bool) -> void:
	var power: bool = p_power && _a_can_power_on
	if _a_power == power:
		return
	
	_set_power(power)
	power_changed.emit(power)

func _set_power(p_power: bool) -> void:
	_a_power = p_power
	_a_Model.set_light_visible(p_power)
	_a_Model.activate_ray(p_power)

func get_power() -> bool:
	return _a_power

func set_can_power_on(p_can_power_on: bool) -> void:
	_a_can_power_on = p_can_power_on
	_a_Rotate_Menu.set_turn_on_off_visible(p_can_power_on)
	if !p_can_power_on:
		set_power(false)

func get_projector_texture() -> ImageTexture:
	return _a_projector_texture

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Model"] = _a_Model.get_save_data()
	data[&"Can_Power_On"] = _a_can_power_on
	data[&"Power"] = _a_power
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Model.load_data(p_data[&"Model"])
	_a_can_power_on = p_data[&"Can_Power_On"]
	_a_Rotate_Menu.set_turn_on_off_visible(p_data[&"Can_Power_On"])
	_a_power = p_data[&"Power"]

func load_data_init() -> void:
	_a_Model.load_data_init()

func _on_Model_ray_collided(p_collider: Object, p_point: Vector3, p_normal: Vector3) -> void:
	model_ray_collided.emit(p_collider, p_point, p_normal)

func _on_Interactions_interacted_empty() -> void:
	open_rotate_menu()
