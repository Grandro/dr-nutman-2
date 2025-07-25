extends Node

signal battle_started()
signal battle_ended()

var _a_Popup_Scene = preload("res://Global_Scenes/Battle_System/Popup.tscn")

const _a_MAIN_PATH = "Navigation/Tilemaps/Same_As_1"

@onready var _a_Party_Member_HUD = get_node("Party_Member_HUD")

var _a_main = null
var _a_player = null
var _a_enemies = []
var _a_party_members = []

func _ready():
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)

func add_instance_main(p_instance):
	_a_main.add_child(p_instance)

func instantiate_popup(p_to, p_type, p_text):
	var instance = _a_Popup_Scene.instantiate()
	instance.set_text.call_deferred(p_text)
	match p_type:
		"Damage": instance.set_color.call_deferred(Battle_System.a_DAMAGE_COLOR)
		"Heal": instance.set_color.call_deferred(Battle_System.a_HEAL_COLOR)
	
	var pos = p_to.get_global_position()
	var offset = p_to.a_popup_offset
	instance.set_global_position(pos + offset)
	add_instance_main(instance)

func deal_damage(p_from, p_to, p_velocity, p_strength):
	var dmg = p_from.a_ATK - p_to.a_DEF
	var dir_vec = p_velocity * p_strength
	instantiate_popup(p_to, "Damage", str(dmg))
	
	p_to.damage(dmg)
	p_to.knockback(dir_vec)

func is_point_in_range(p_center, p_pos, p_radius):
	return p_center.distance_to(p_pos) <= p_radius

func is_any_enemy_in_range(p_center, p_radius):
	for enemy in _a_enemies:
		if is_point_in_range(p_center, enemy.position, p_radius):
			return true
	
	return false

func is_any_party_member_in_range(p_center, p_radius):
	for party_member in _a_party_members:
		if is_point_in_range(p_center, party_member.position, p_radius):
			return true
	
	return false

func get_nearest_party_member(p_pos, p_exclude = null):
	var distances = []
	for party_member in _a_party_members:
		if party_member != p_exclude:
			var distance = p_pos.distance_to(party_member.position)
			distances.push_back([distance, party_member])
	
	if distances.is_empty():
		return null
	
	distances.sort_custom(Callable(Global.ArraySorter, "sort_low"))
	var nearest = distances[0][1]
	
	return nearest

func get_nearest_enemy(p_pos, p_exclude = null):
	var distances = []
	for enemy in _a_enemies:
		if enemy != p_exclude:
			var distance = p_pos.distance_to(enemy.position)
			distances.push_back([distance, enemy])
	
	if distances.is_empty():
		return null
	
	distances.sort_custom(Callable(Global.ArraySorter, "sort_low"))
	var nearest = distances[0][1]
	
	return nearest

func _on_Scene_Manager_scene_changed(p_curr_scene):
	return
	if !(p_curr_scene is MapBase):
		return
	
	var player = Global.get_player()
	player.died.connect(_on_Party_Member_died.bind(player))
	battle_started.connect(player._on_battle_started)
	battle_ended.connect(player._on_battle_ended)
	
	_a_main = p_curr_scene.get_node(_a_MAIN_PATH)
	_a_player = player
	
	_a_Party_Member_HUD.clear_entries()
	_a_Party_Member_HUD.hide()

func _on_Encounter_area_entered(p_encounter):
	var data = Databases.get_data("Party_Members")
	for key in Global.a_party_members:
		var args = data[key]
		var instance = null
		if key == "Player":
			instance = _a_player
		else:
			var path = args["Battle_Path"]
			var scene = load(path)
			instance = scene.instantiate()
			instance.died.connect(_on_Party_Member_died.bind(instance))
			battle_started.connect(instance._on_battle_started)
			battle_started.connect(instance._on_battle_ended)
		
		var curr_args = Global.a_party_members[key]
		var curr_stats = curr_args["Stats"]
		var popup_offset = args["Popup_Offset"]
		instance.set_encounter(p_encounter)
		instance.set_max_HP(curr_stats["HP"])
		instance.set_max_SP(curr_stats["SP"])
		instance.set_HP.call_deferred(curr_stats["HP"])
		instance.set_SP.call_deferred(curr_stats["SP"])
		instance.set_ATK.call_deferred(curr_stats["ATK"])
		instance.set_MAG.call_deferred(curr_stats["MAG"])
		instance.set_DEF.call_deferred(curr_stats["DEF"])
		instance.set_SPEED.call_deferred(curr_stats["SPEED"])
		instance.set_popup_offset(Vector2(popup_offset["X"], popup_offset["Y"]))
		
		_a_party_members.push_back(instance)
		_a_Party_Member_HUD.add_entry(instance, key)
		
		if key == "Player":
			continue
		
		var player_pos = _a_player.get_global_position()
		instance.set_global_position(player_pos)
		add_instance_main(instance)
	
	p_encounter.set_party_members(_a_party_members)
	_a_enemies = p_encounter.get_enemies()
	_a_Party_Member_HUD.show()
	
	battle_started.emit()

func _on_Encounter_area_exited():
	for instance in _a_party_members:
		if instance != _a_player:
			instance.queue_free()
	
	_a_party_members.clear()
	_a_enemies = []
	
	_a_Party_Member_HUD.clear_entries()
	_a_Party_Member_HUD.hide()
	
	battle_ended.emit()

func _on_Enemy_died(p_instance):
	print(p_instance.get_name(), " died.")

func _on_Party_Member_died(p_instance):
	print(p_instance.get_name(), " died.")
