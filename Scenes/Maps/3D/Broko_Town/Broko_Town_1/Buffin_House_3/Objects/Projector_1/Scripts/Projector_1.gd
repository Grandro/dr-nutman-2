extends Node3DObject

signal model_ray_collided(p_collider, p_pos)

@onready var _a_Model = get_node("Model")
@onready var _a_Interactions = get_node("Interactions")
@onready var _a_VP = get_node("VP")
@onready var _a_Rotate_Menu = get_node("Rotate_Menu")

func _ready():
	super()
	_a_Model.ray_collided.connect(_on_Model_ray_collided)
	_a_Interactions.interacted.connect(_on_Interactions_interacted)
	
	await RenderingServer.frame_post_draw
	var vp_image = _a_VP.get_texture().get_image()
	var projector_texture = ImageTexture.create_from_image(vp_image)
	_a_Model.set_light_projector(projector_texture)

func open_rotate_menu():
	_a_Rotate_Menu.open(_a_Model)

func activate_model_ray(p_activate):
	_a_Model.activate_ray(p_activate)

func set_model_light_visible(p_visible):
	_a_Model.set_light_visible(p_visible)

func get_save_data():
	var data = super()
	data["Model"] = _a_Model.get_save_data()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Model.load_data(p_data["Model"])

func _on_Model_ray_collided(p_collider, p_point, p_normal):
	model_ray_collided.emit(p_collider, p_point, p_normal)

func _on_Interactions_interacted():
	var interaction_count = _a_Interactions.get_interaction_count(0)
	match interaction_count:
		1:
			var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
			cutscene_system_si.cutscene("Puzzle_2", "Start")
		2:
			var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
			cutscene_system_si.cutscene("Puzzle_2", "Projector_Start")
		_:
			open_rotate_menu()
