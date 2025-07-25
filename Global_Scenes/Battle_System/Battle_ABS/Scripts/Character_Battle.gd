extends CharacterBody3D

signal died()

@export var _e_key: String = ""
@export var _e_state: String = "State"

@export var _e_lock_cd: float = 10.0 # Duration of locking a target
@export var _e_gen_points: int = 10 # Amount of points generated to choose move points
@export var _e_avoid_range: int = 200 # Radius which decides when the character starts to avoid
@export var _e_party_member_prio: float = 0.5 # Factor of avoiding party members
@export var _e_enemy_prio: float = 0.5 # Factor of avoiding enemies

@export var _e_walk_speed: int = 150
@export var _e_knockback_strength: int = 300
@export var _e_knockback_duration: float = 0.25
@export var _e_till_idle: float = 2.0
@export var _e_SP_regen_cd: float = 10.0
@export var _e_SP_regen_amount: int = 1
@export var _e_popup_offset: Vector2 = Vector2.ZERO

var _a_Knockback_Scene = preload("res://Global_Scenes/Battle_System/Battle_ABS/Enemies/Scripts/Enemy_Battle.gd")

@onready var _a_Hitbox = get_node("Hitbox")
@onready var _a_Hurtbox = get_node("Hurtbox")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Idle_CD = get_node("Idle_CD")
@onready var _a_SP_Regen = get_node("SP_Regen")
@onready var _a_Lock_CD = get_node("Lock_CD")
@onready var _a_Knockbacks = get_node("Knockbacks")

var _a_encounter = null

var _a_can_move = 0 # 0 = enabled, > 0 = disabled
var _a_velocity = Vector2.ZERO
var _a_speed = _e_walk_speed
var _a_state_tmp = "Idle"
var _a_dir = "Down"
var _a_popup_offset = Vector2.ZERO
var _a_path = PackedVector2Array()
var _a_target = null
var _a_battle_state = "Random"

var _a_possible_points = []

var _a_max_HP = -1
var _a_max_SP = -1
var _a_HP = -1
var _a_SP = -1
var _a_ATK = -1
var _a_MAG = -1
var _a_DEF = -1
var _a_SPEED = -1

func _ready():
	_a_SP_Regen.timeout.connect(_on_SP_Regen_timeout)
	
	set_state_tmp(_e_state)

func play_anim(p_name):
	_a_Anims.play(p_name)

func update_anim():
	var anim_name = "%s_%s" % [_a_state_tmp, _a_dir]
	play_anim(anim_name)

func knockback(p_dir_vec):
	if _a_Knockbacks.get_child_count() == 0:
		set_state_tmp("Knockback")
		update_anim()
		_a_can_move += 1
	
	_instantiate_knockback(p_dir_vec)

func _instantiate_knockback(p_dir_vec):
	var instance = _a_Knockback_Scene.instantiate()
	instance.timeout.connect(_on_Knockback_timeout.bind(instance))
	instance.tree_exited.connect(_on_Knockback_tree_exited)
	var velocity_ = p_dir_vec + _a_velocity
	instance.set_init_velocity(velocity_)
	instance.set_velocity(velocity_)
	instance.set_wait_time(_e_knockback_duration)
	
	_a_Knockbacks.add_child(instance)

func _process_knockbacks():
	if _a_Knockbacks.get_child_count() > 0:
		for child in _a_Knockbacks.get_children():
			var init_velocity = child.get_init_velocity()
			var end_velocity = Vector2.ZERO
			var time_left = child.get_time_left()
			var t = 1 - (time_left / _e_knockback_duration)
			_a_velocity += init_velocity.lerp(end_velocity, t)
		return true
	
	return false

func _avoid():
	var best_point = _gen_best_point(100)
	_update_path(best_point)

func _update_path(_p_point):
	var _global_pos = get_global_position()
	#a_path = Nav_System.find_path(self, global_pos, p_point)
	if _a_path.size() > 0:
		_a_path.remove(0)

func _get_possible_points_rated(p_distance):
	var point_degrees = 360.0 / _e_gen_points
	var up_vec = Vector2(0, -p_distance)
	
	_a_possible_points.clear()
	for i in _e_gen_points:
		var global_pos = get_global_position()
		var degrees = i * point_degrees
		var radians = deg_to_rad(degrees)
		var rotated_vec = up_vec.rotated(radians)
		var point = global_pos + rotated_vec
		
		if !_a_encounter.is_inside_area(point):
			continue
		
		if !false:#Nav_System.is_point_passable(self, point)
			continue
		
		var rating = 0
		# Party members
		var party_members = _a_encounter.get_party_members(self)
		for instance in party_members:
			var instance_global_pos = instance.get_global_position()
			var distance = instance_global_pos.distance_to(point)
			rating += distance * _e_party_member_prio
		
		# Enemies
		var enemies = _a_encounter.get_enemies(self)
		for instance in enemies:
			var instance_global_pos = instance.get_global_position()
			var distance = instance_global_pos.distance_to(point)
			rating += distance * _e_enemy_prio
		
		_a_possible_points.push_back([rating, point])
	
	_a_possible_points.sort_custom(Global.sort_high)
	
	return _a_possible_points

func _gen_best_point(p_distance):
	var points = _get_possible_points_rated(p_distance)
	var best_point = Vector2.INF
	if !points.is_empty():
		best_point = points[0][1]
	
	return best_point

func set_encounter(p_encounter):
	_a_encounter = p_encounter

func set_max_HP(p_value):
	_a_max_HP = p_value
	_a_HP = min(_a_HP, p_value)

func set_max_SP(p_value):
	_a_max_SP = p_value
	_a_SP = min(_a_SP, p_value)

func set_HP(p_value):
	if p_value <= 0:
		_a_HP = 0
		died.emit()
	else:
		_a_HP = p_value

func set_SP(p_value):
	if p_value >= _a_max_SP:
		_a_SP = _a_max_SP
		_a_SP_Regen.stop()
	else:
		_a_SP = p_value
		if _a_SP_Regen.is_stopped():
			_a_SP_Regen.start(_e_SP_regen_cd)

func set_ATK(p_value):
	_a_ATK = p_value

func set_DEF(p_value):
	_a_DEF = p_value

func set_SPEED(p_value):
	_a_SPEED = p_value

func set_state(p_state):
	_e_state = p_state
	set_state_tmp(p_state)

func set_state_tmp(p_state_tmp):
	_a_state_tmp = p_state_tmp

func set_speed(p_speed):
	_a_speed = p_speed

func set_dir(p_dir):
	_a_dir = p_dir

func set_popup_offset(p_offset):
	_a_popup_offset = p_offset

func set_battle_state(p_battle_state):
	_a_battle_state = p_battle_state

func get_hurtbox_pos():
	return _a_Hurtbox.get_global_position()

func _on_SP_Regen_timeout():
	set_SP(_a_SP + _e_SP_regen_amount)

func _on_battle_started():
	pass

func _on_battle_ended():
	pass

func _on_Knockback_timeout(p_instance):
	p_instance.queue_free()

func _on_Knockback_tree_exited():
	if _a_Knockbacks.get_child_count() == 0:
		set_state_tmp("Stop")
		_a_can_move -= 1

func _draw():
	for args in _a_possible_points:
		var local_pos = to_local(global_position)
		#draw_line(local_pos, to_local(args[1]), Color.WHITE)
