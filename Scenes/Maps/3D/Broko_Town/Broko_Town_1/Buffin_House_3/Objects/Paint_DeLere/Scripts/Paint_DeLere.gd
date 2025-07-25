extends Character3DObject

@export var _e_ray_range : float = 2.0
@export var _e_player_comment_amount : int = 4
@export var _e_self_comment_amount : int = 4
@export var _e_comment_time : float = 5.0
@export var _e_comment_cd : float = 5.0

var _a_Canvas_Scene = preload("res://Scenes/NPC/3D/Buffins/Paint_DeLere/Canvases/1.tscn")

@onready var _a_Display = get_node("Display")
@onready var _a_Interactions = get_node("Interactions")
@onready var _a_Movement = get_node("Movement")
@onready var _a_Movement_Nav_Agent = get_node("Movement/Nav_Agent")
@onready var _a_States = get_node("States")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Adjust_Ray = get_node("Adjust_Ray")
@onready var _a_Comment_Timer = get_node("Comment_Timer")
@onready var _a_Comment_CD = get_node("Comment_CD")

var _a_player = null
var _a_projector = null
var _a_canvas = null

var _a_paint_from_projector = false
var _a_normal = Vector3.ZERO
var _a_final_pos = Vector3.ZERO
var _a_ray_collide_type = "" # Player/Self/Canvas/Terrain
var _a_painting = false
var _a_walking = false
var _a_dodging = false

func _ready():
	super()
	_a_Comment_Timer.timeout.connect(_on_Comment_Timer_timeout)
	_a_Comment_CD.timeout.connect(_on_Comment_CD_timeout)

func _ray_collided_self():
	if _a_dodging:
		return
	
	_a_Adjust_Ray.set_enabled(true)
	
	var nav_map = get_world_3d().get_navigation_map()
	for degrees in [90, -90]:
		var radians = deg_to_rad(degrees)
		var adjust_vec = _a_normal.rotated(Vector3.UP, radians)
		var pos = _a_final_pos + adjust_vec
		pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
		
		var distance = global_position.distance_to(pos)
		if distance < 0.5:
			continue
		pos.y = 1.0
		
		_a_Adjust_Ray.set_global_position(Vector3(_a_final_pos.x, 1.0, _a_final_pos.z))
		var local_pos = _a_Adjust_Ray.to_local(pos)
		_a_Adjust_Ray.set_target_position(local_pos)
		_a_Adjust_Ray.force_raycast_update()
		
		if !_a_Adjust_Ray.is_colliding():
			_walk_to_pos(pos)
			_a_dodging = true
			break
	
	_a_Adjust_Ray.set_enabled(false)

func _ray_collided_terrain(p_pos, p_normal):
	_a_normal = p_normal
	_a_final_pos = p_pos + p_normal * _e_ray_range * 0.75
	_a_final_pos.y = 0.0
	
	if _a_dodging:
		return
	
	if _a_painting:
		var distance = global_position.distance_to(_a_final_pos)
		if distance > _e_ray_range:
			_walk_to_pos(_a_final_pos)
		else:
			var needed_dir = Global.get_dir_to_pos(global_position, p_pos)
			var curr_dir = _a_Movement.get_dir()
			if needed_dir != curr_dir:
				_place_canvas()
	else:
		_walk_to_pos(_a_final_pos)

func _place_canvas():
	var dir = Global.get_vec_dir(-_a_normal)
	_a_Movement.set_dir(dir)
	_a_Anims.update_anim()
	
	var canvas_dir = Global.get_opposite_dir(dir)
	_a_canvas.set_global_position(global_position - _a_normal)
	_a_canvas.comph().call_comp("Display", "update_billboard_rotation")
	_a_canvas.comph().call_comp("Movement", "set_dir", [canvas_dir])
	_a_canvas.comph().call_comp("Anims", "update_anim")

func _pick_up_canvas():
	_a_canvas.set_global_position(Vector3.ZERO)
	_set_painting(false)

func _walk_to_pos(p_pos):
	if !_a_walking:
		_pick_up_canvas()
	_a_States.set_state("Walk")
	_a_Movement_Nav_Agent.set_avoidance_enabled(true)
	_a_Movement_Nav_Agent.set_path([p_pos])
	_a_walking = true

func set_player(p_player):
	_a_player = p_player

func set_projector(p_projector):
	_a_projector = p_projector

func set_billboard(p_billboard):
	_a_Display.set_billboard(p_billboard)
	if _a_canvas != null:
		_a_canvas.comph().call_comp("Display", "set_billboard", [p_billboard])

func set_paint_from_projector(p_paint_from_projector):
	_a_paint_from_projector = p_paint_from_projector
	
	if p_paint_from_projector:
		_a_projector.model_ray_collided.connect(_on_Projector_model_ray_collided)
		_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)
		
		_a_canvas = _a_Canvas_Scene.instantiate()
		_a_canvas.set_as_top_level(true)
		_a_canvas.set_name("Canvas_Paint_DeLere")
		add_child(_a_canvas)
		
		#var light_projector = p_projector.get_model_light_projector()
		var billboard = _a_Display.get_billboard()
		#_a_canvas.comph().call_comp("Display", "set_picture_texture", [light_projector])
		_a_canvas.comph().call_comp("Display", "set_billboard", [billboard])
	else:
		_a_projector.model_ray_collided.disconnect(_on_Projector_model_ray_collided)
		_a_Movement_Nav_Agent.path_finished.disconnect(_on_Movement_Nav_Agent_path_finished)
		
		_a_canvas.queue_free()
		_a_canvas = null

func _set_painting(p_painting):
	_a_Interactions.set_look_at_player(!p_painting)
	
	var display_comp = _a_canvas.comph().get_comp("Display")
	if p_painting:
		var progress = display_comp.get_picture_progress()
		display_comp.start_tween_picture_progress(progress, 0.9, 3.0)
		_a_States.set_state("Paint")
	else:
		display_comp.stop_tween_picture_progress()
		_a_States.set_state("Idle")
	
	_a_Anims.update_anim()
	_a_painting = p_painting

func get_save_data():
	var data = super()
	data["Comment_Timer"] = _a_Comment_Timer.get_time_left()
	data["Comment_CD"] = _a_Comment_CD.get_time_left()
	var projector_path = ""
	if _a_projector != null:
		projector_path = _a_projector.get_path()
	data["Projector_Path"] = projector_path
	data["Paint_From_Projector"] = _a_paint_from_projector
	data["Normal"] = _a_normal
	data["Final_Pos"] = _a_final_pos
	data["Ray_Collide_Type"] = _a_ray_collide_type
	data["Painting"] = _a_painting
	data["Walking"] = _a_walking
	data["Dodging"] = _a_dodging
	
	return data

func load_data(p_data):
	super(p_data)
	if p_data["Comment_Timer"] > 0.0:
		_a_Comment_Timer.start(p_data["Comment_Timer"])
	if p_data["Comment_CD"] > 0.0:
		_a_Comment_CD.start(p_data["Comment_CD"])
	_a_projector = get_node_or_null(p_data["Projector_Path"])
	if _a_projector != null:
		set_paint_from_projector(p_data["Paint_From_Projector"])
		_set_painting(p_data["Painting"])
	_a_normal = p_data["Normal"]
	_a_final_pos = p_data["Final_Pos"]
	_a_ray_collide_type = p_data["Ray_Collide_Type"]
	_a_walking = p_data["Walking"]
	_a_dodging = p_data["Dodging"]

func _on_Comment_Timer_timeout():
	var dialogue_system_si = Global.get_singleton(self, "Dialogue_System")
	match _a_ray_collide_type:
		"Player":
			var rndm = randi() % _e_player_comment_amount + 1
			var key = "Puzzle_2_Comment_1_%d" % rndm
			dialogue_system_si.dialogue(key, null, "Sub")
			dialogue_system_si.set_dialogue_completed_cb(key, _CB_dialogue_completed)
		
		"Self":
			var rndm = randi() % _e_self_comment_amount + 1
			var key = "Puzzle_2_Comment_2_%d" % rndm
			dialogue_system_si.dialogue(key, null, "Sub")
			dialogue_system_si.set_dialogue_completed_cb(key, _CB_dialogue_completed)

func _on_Comment_CD_timeout():
	match _a_ray_collide_type:
		"Player": _a_Comment_Timer.start(_e_comment_time)
		"Self": _a_Comment_Timer.start(_e_comment_time)

func _on_Movement_Nav_Agent_path_finished():
	_a_walking = false
	_a_dodging = false
	_a_Movement_Nav_Agent.set_avoidance_enabled(false)
	_place_canvas()
	
	match _a_ray_collide_type:
		"Player": _set_painting(false)
		"Self": _set_painting(false)
		"Canvas": _set_painting(true)
		"Terrain": _set_painting(true)

func _on_Projector_model_ray_collided(p_collider, p_pos, p_normal):
	var paint_delere = self
	match p_collider:
		_a_player:
			if _a_ray_collide_type != "Player":
				if !_a_walking:
					_set_painting(false)
				_a_Comment_Timer.start(_e_comment_time)
				_a_Comment_CD.stop()
				_a_ray_collide_type = "Player"
		
		paint_delere:
			_ray_collided_self()
			if _a_ray_collide_type != "Self":
				if !_a_walking:
					_set_painting(false)
				_a_Comment_Timer.start(_e_comment_time)
				_a_Comment_CD.stop()
				_a_ray_collide_type = "Self"
		
		_a_canvas:
			if _a_ray_collide_type != "Canvas":
				if !_a_walking:
					_set_painting(true)
				_a_Comment_Timer.stop()
				_a_Comment_CD.stop()
				_a_ray_collide_type = "Canvas"
		
		_:
			if _a_ray_collide_type != "Terrain":
				if !_a_walking:
					_set_painting(true)
			
			_ray_collided_terrain(p_pos, p_normal)
			if _a_ray_collide_type != "Terrain":
				_a_Comment_Timer.stop()
				_a_Comment_CD.stop()
				_a_ray_collide_type = "Terrain"

func _CB_dialogue_completed(_p_key):
	_a_Comment_CD.start(_e_comment_cd)
