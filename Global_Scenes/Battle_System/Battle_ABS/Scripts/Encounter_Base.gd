extends Node2D

signal area_entered(p_instance)
signal area_exited()

@export var _e_key: String = ""
@export var _e_respawn_time: float = 20.0
@export var _e_enemy_scenes: Array[ABSEnemy] = []

@onready var _a_Area = get_node("Area")
@onready var _a_Collision = get_node("Area/Collision")
@onready var _a_Respawn = get_node("Respawn")

var _a_party_members = []
var _a_enemies = []

func _ready():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	var battle_system_si = Global.get_singleton(self, "Battle_System")
	var abs = battle_system_si.get_abs()
	area_entered.connect(abs._on_Encounter_area_entered)
	area_exited.connect(abs._on_Encounter_area_exited)
	_a_Area.body_entered.connect(_on_Area_body_entered)
	_a_Area.body_exited.connect(_on_Area_body_exited)
	scene_manager_si.scene_changed.connect(_on_Scene_Manager_scene_changed)

func set_party_members(p_members):
	_a_party_members = p_members

func get_party_members(p_except = null):
	var party_members = []
	for instance in _a_party_members:
		if instance != p_except:
			party_members.push_back(instance)
	
	return party_members

func get_enemies(p_except = null):
	var enemies = []
	for instance in _a_enemies:
		if instance != p_except:
			enemies.push_back(instance)
	
	return enemies

func is_inside_area(p_point):
	var shape = _a_Collision.get_shape()
	var shape_class = shape.get_class()
	match shape_class:
		"RectangleShape2D":
			var global_pos = get_global_position()
			var size = shape.get_extents()
			if p_point.x < global_pos.x - size.x:
				return false
			if p_point.x > global_pos.x + size.x:
				return false
			if p_point.y < global_pos.y - size.y:
				return false
			if p_point.y > global_pos.y + size.y:
				return false
	
	return true

func _on_Area_body_entered(_p_instance):
	# Make sure only Player triggers this
	area_entered.emit(self)

func _on_Area_body_exited(_p_instance):
	# Make sure only Player triggers this
	area_exited.emit()

func _on_Scene_Manager_scene_changed(p_curr_scene):
	var enemies_data = Databases.get_data("Enemies")
	for scene in _e_enemy_scenes:
		var instance = scene.instantiate()
		var key = instance.get_key()
		var data = enemies_data[key]
		var stats = data["Stats"]
		var popup_offset = data["Popup_Offset"]
		var battle_system_si = Global.get_singleton(self, "Battle_System")
		var abs = battle_system_si.get_abs()
		instance.died.connect(abs._on_Enemy_died.bind(instance))
		instance.set_encounter(self)
		instance.set_max_HP(stats["HP"])
		instance.set_max_SP(stats["SP"])
		instance.set_HP.call_deferred(stats["HP"])
		instance.set_SP.call_deferred(stats["SP"])
		instance.set_ATK.call_deferred(stats["ATK"])
		instance.set_MAG.call_deferred(stats["MAG"])
		instance.set_DEF.call_deferred(stats["DEF"])
		instance.set_SPEED.call_deferred(stats["SPEED"])
		instance.set_hud_data.call_deferred(stats["HP"], stats["SP"])
		instance.set_popup_offset(Vector2(popup_offset["X"], popup_offset["Y"]))
		instance.set_global_position(global_position)
		
		_a_enemies.push_back(instance)
		
		abs.battle_started.connect(instance._on_battle_started)
		abs.battle_ended.connect(instance._on_battle_ended)
		
		var same_as = p_curr_scene.get_node("Navigation/Tilemaps/Same_As")
		same_as.add_child(instance)
