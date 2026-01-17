extends Node3DObject
class_name ObjectProjectorBase

signal model_ray_collided(p_collider: Object, p_pos: Vector3)
signal power_changed(p_power: bool)

@onready var _a_Model: ObjectProjectorModel = get_node("Model")
@onready var _a_Interactions: CompInteractions3D = get_node("Interactions")
@onready var _a_VP: SubViewport = get_node("VP")
@onready var _a_Rotate_Menu: ObjectProjectorRotateMenu = get_node("Rotate_Menu")

var _a_projector_texture: ImageTexture

func _ready() -> void:
	super()
	_a_Model.ray_collided.connect(_on_Model_ray_collided)
	_a_Interactions.interacted.connect(_on_Interactions_interacted)
	
	_a_Rotate_Menu.set_projector(self)
	_a_Rotate_Menu.set_model(_a_Model)
	
	await RenderingServer.frame_post_draw
	var vp_image: Image = _a_VP.get_texture().get_image()
	_a_projector_texture = ImageTexture.create_from_image(vp_image)
	_a_Model.set_light_projector(_a_projector_texture)

func open_rotate_menu() -> void:
	_a_Rotate_Menu.open()

func set_power(p_power: bool) -> void:
	_a_Model.set_light_visible(p_power)
	_a_Model.activate_ray(p_power)
	
	power_changed.emit(p_power)

func get_projector_texture() -> ImageTexture:
	return _a_projector_texture

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Model"] = _a_Model.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Model.load_data(p_data[&"Model"])

func load_data_init() -> void:
	_a_Model.load_data_init()

func _on_Model_ray_collided(p_collider: Object, p_point: Vector3, p_normal: Vector3) -> void:
	model_ray_collided.emit(p_collider, p_point, p_normal)

func _on_Interactions_interacted() -> void:
	open_rotate_menu()
