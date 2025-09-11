extends Node3DObject

signal model_ray_collided(p_collider, p_pos)
signal power_changed(p_power)

@onready var _a_Model = get_node("Model")
@onready var _a_Interactions = get_node("Interactions")
@onready var _a_VP = get_node("VP")
@onready var _a_Rotate_Menu = get_node("Rotate_Menu")

var _a_projector_texture = null

func _ready():
	super()
	_a_Model.ray_collided.connect(_on_Model_ray_collided)
	_a_Interactions.interacted.connect(_on_Interactions_interacted)
	
	_a_Rotate_Menu.set_projector(self)
	_a_Rotate_Menu.set_model(_a_Model)
	
	await RenderingServer.frame_post_draw
	var vp_image = _a_VP.get_texture().get_image()
	_a_projector_texture = ImageTexture.create_from_image(vp_image)
	_a_Model.set_light_projector(_a_projector_texture)

func open_rotate_menu():
	_a_Rotate_Menu.open()

func set_power(p_power):
	_a_Model.set_light_visible(p_power)
	_a_Model.activate_ray(p_power)
	
	power_changed.emit(p_power)

func get_projector_texture():
	return _a_projector_texture

func get_save_data():
	var data = super()
	data["Model"] = _a_Model.get_save_data()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Model.load_data(p_data["Model"])

func load_data_init():
	_a_Model.load_data_init()

func _on_Model_ray_collided(p_collider, p_point, p_normal):
	model_ray_collided.emit(p_collider, p_point, p_normal)

func _on_Interactions_interacted():
	open_rotate_menu()
