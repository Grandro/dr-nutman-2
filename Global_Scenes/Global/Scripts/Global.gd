extends Node

signal use_joy_changed()
signal item_amount_changed(p_key: StringName, p_amount: int, p_diff: int)
signal pm_stat_changed(p_key: StringName, p_stat: StringName, p_value: int)
signal trans_finished()
signal curr_camera_changed(p_curr_camera: Node)

@export var _e_version: StringName = &"0.0.1"

var _a_Default_Cursor: Texture2D = preload("res://Global_Resources/Sprites/Cursors/Default.png")
var _a_Trans_Shader: ShaderMaterial = preload("res://Global_Resources/Materials/2D/Trans.tres")

const _a_SAVES_PATH: String = "user://Saves/"
const _a_SAVE_PATH: String = "user://Saves/%s/Data.save"
const _a_TITLE_SCREEN_SCENE_PATH: String = "res://Scenes/Title_Screen/Title_Screen.tscn"
const _a_ITEM_TYPE_ICON_PATH: String = "res://Global_Resources/Sprites/Icons/Item_Types/%s/%s.png"
const _a_ITEM_PATH: String = "res://Global_Resources/Sprites/Items/%s.png"
const _a_POPUP_PATH: String = "res://Global_Resources/Sprites/Popups/%s.png"
const _a_POPUP_TYPES: Array[StringName] = [&"Exclamation", &"Question", &"Speech"]
const _a_EQUIPMENT_GROUPS: Array[StringName] = [&"Head", &"Torso", &"Legs", &"Feet", &"Weapon", &"Shield"]
const _a_LAYOUTS: Array[StringName] = [&"Top_Left", &"Top_Right", &"Bottom_Right", &"Bottom_Left",
									   &"Center_Left", &"Center_Top", &"Center_Right", &"Center_Bottom",
									   &"Center"]

@onready var _a_Play_Time: Timer = get_node("Play_Time")
@onready var _a_Trans: ColorRect = get_node("Overlays/Trans")
@onready var _a_Trans_Anims: AnimationPlayer = get_node("Overlays/Trans/Anims")
@onready var _a_Tutato: Node2DObject = get_node("Canvas/Tutato")

var _a_saved_data: Dictionary = {} # Save Data

var _a_player: Node = null
var _a_curr_camera: Node = null
var _a_camera_limit: Dictionary[Side, float] = {} # Match side enum to limit

# VARS TO SAVE
var _a_play_time: int = 0
var _a_party_members: Dictionary = {}
var _a_inventory: Dictionary = {}
var _a_coins: int = 0
var a_for_loop_idxs: Dictionary[String, Variant] = {} # Current values of all for loops in a cutscene
# ------------

# INPUT
var _a_use_joy: bool = false # Is Keyboard active or Joypad?
var _a_joy_connected: bool = false # Is joypad connected?
var _a_joy_type: StringName = &"" # Joy_Letters_Color/Joy_Shapes_Color/Joy_Letters_Neutral
# ------

var _a_base_vp_size: Vector2i = Vector2i.ZERO
var _a_paused: int = 0 # 0 = unpaused, > 0 = paused
var _a_is_root: bool = false # Is direct child of root?

func _ready() -> void:
	_a_Play_Time.timeout.connect(_on_Play_Time_timeout)
	_a_Trans_Anims.animation_finished.connect(_on_Trans_Anims_anim_finished)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	_a_base_vp_size = get_viewport().get_size()
	_a_is_root = get_viewport() == get_tree().get_root()
	
	_create_save_dirs()
	init_camera_limit()
	_init_party_members()
	_init_inventory()
	_init_for_loop_idxs()
	_init_saved_data()
	
	_update_joy()
	
	_a_Trans.set_material(_a_Trans_Shader.duplicate(true))

func _input(p_event: InputEvent) -> void:
	var use_joy: bool = false
	if _a_joy_connected:
		if p_event is InputEventJoypadButton || p_event is InputEventJoypadMotion:
			use_joy = true
	
	var changed_use_joy: bool = use_joy != _a_use_joy
	_a_use_joy = use_joy
	if changed_use_joy:
		use_joy_changed.emit()
	
	if p_event.is_action_pressed(&"Toggle_Fullscreen"):
		var curr_window_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
		var new_window_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN
		if curr_window_mode == new_window_mode:
			new_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(new_window_mode)

func show_trans(p_mask_path: String, p_anim: StringName) -> void:
	if !p_mask_path.is_empty():
		var tex: Texture2D = load(p_mask_path)
		var mat: Material = _a_Trans.get_material()
		mat.set_shader_parameter(&"mask", tex)
	
	_a_Trans_Anims.play(p_anim)

func seek_trans_anim(p_seconds: float, p_update: bool = false) -> void:
	_a_Trans_Anims.seek(p_seconds, p_update)

func pause() -> void:
	_a_paused += 1
	if _a_is_root && _a_paused == 1:
		get_tree().set_pause(true)

func unpause() -> void:
	_a_paused -= 1
	if _a_is_root && _a_paused == 0:
		get_tree().set_pause(false)

func start_game() -> void:
	var progress_si: Progress = get_singleton(self, "Progress")
	progress_si.init()
	_init_party_members()
	_init_inventory()
	_init_for_loop_idxs()
	_init_saved_data()
	
	# GAIN ITEMS
	#change_item_amount("Cookie", 67)
	#change_item_amount("Handful_Peanuts_Cracked", 18)
	#change_item_amount("Handful_Peanuts_Uncracked", 18)
	#change_item_amount("Party_Hat_1", 18)
	#change_item_amount("Disposable_Glove", 1)
	#change_item_amount("Citrin_Shield", 1)
	# ---------------
	
	# ACTIVATE PARTY MEMBERS
	activate_party_member(&"Dr_Nutman")
	#activate_party_member("Buffin_Assistant_1")
	# ----------------------
	
	_a_Play_Time.start()

func reset() -> void:
	var audio_manager_si: Audio_Manager = get_singleton(self, "Audio_Manager")
	var cutscene_system_si: Cutscene_System = get_singleton(self, "Cutscene_System")
	var progress_si: Progress = get_singleton(self, "Progress")
	var main_menu_si: Main_Menu = get_singleton(self, "Main_Menu")
	audio_manager_si.reset()
	cutscene_system_si.reset()
	progress_si.reset()
	main_menu_si.reset()
	
	_a_player = null
	_a_curr_camera = null
	_a_Play_Time.stop()
	_a_play_time = 0

func execute_expr_from_data(p_data: Dictionary) -> Variant:
	var instance_key: StringName = p_data[&"Instance_Key"]
	var expression: String = p_data[&"Expression"]
	var type: StringName = p_data[&"Type"]
	var instance: Node
	match type:
		&"Object":
			var object: Node = get_object(instance_key)
			var comp: String = p_data[&"Comp"]
			instance = object.comph().get_comp(comp)
		&"Singleton":
			instance = get_singleton(self, instance_key)
		&"Curr_Scene":
			var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
			instance = scene_manager_si.get_curr_scene_instance()
	
	var expr: Expression = Expression.new()
	var error: Error = expr.parse(expression)
	var value: Variant = null
	if error == OK: 
		value = expr.execute([], instance, true)
	else:
		print(expr.get_error_text())
	
	return value

func cleanup_map() -> void:
	var cutscene_system_si: Cutscene_System = get_singleton(self, "Cutscene_System")
	cutscene_system_si.cleanup_map()

func activate_party_member(p_key: StringName) -> void:
	_a_party_members[p_key][&"Active"] = true

func deactivate_party_member(p_key: StringName) -> void:
	_a_party_members[p_key][&"Active"] = false

func _update_party_member_stats(p_key: StringName, p_stats: StatsData, p_equip: bool) -> void:
	var max_HP: int = get_party_member_stat(p_key, &"Max_HP")
	var max_SP: int = get_party_member_stat(p_key, &"Max_SP")
	var ATK: int = get_party_member_stat(p_key, &"ATK")
	var MAG: int = get_party_member_stat(p_key, &"MAG")
	var DEF: int = get_party_member_stat(p_key, &"DEF")
	var SPEED: int = get_party_member_stat(p_key, &"SPEED")
	var LUCK: int = get_party_member_stat(p_key, &"LUCK")
	
	if p_equip:
		set_party_member_stat(p_key, &"Max_HP", max_HP + p_stats.get_HP())
		set_party_member_stat(p_key, &"Max_SP", max_SP + p_stats.get_SP())
		set_party_member_stat(p_key, &"ATK", ATK + p_stats.get_ATK())
		set_party_member_stat(p_key, &"MAG", MAG + p_stats.get_MAG())
		set_party_member_stat(p_key, &"DEF", DEF + p_stats.get_DEF())
		set_party_member_stat(p_key, &"SPEED", SPEED + p_stats.get_SPEED())
		set_party_member_stat(p_key, &"LUCK", LUCK + p_stats.get_LUCK())
	else:
		set_party_member_stat(p_key, &"Max_HP", max_HP - p_stats.get_HP())
		set_party_member_stat(p_key, &"Max_SP", max_SP - p_stats.get_SP())
		set_party_member_stat(p_key, &"ATK", ATK - p_stats.get_ATK())
		set_party_member_stat(p_key, &"MAG", MAG - p_stats.get_MAG())
		set_party_member_stat(p_key, &"DEF", DEF - p_stats.get_DEF())
		set_party_member_stat(p_key, &"SPEED", SPEED - p_stats.get_SPEED())
		set_party_member_stat(p_key, &"LUCK", LUCK - p_stats.get_LUCK())

func equip_party_member(p_pm_key: StringName, p_group: StringName, p_key: StringName) -> void:
	unequip_party_member(p_pm_key, p_group)
	
	var args: Dictionary = _a_party_members[p_pm_key][&"Equipables"]
	if !p_key.is_empty():
		var data: EquipableData = Databases.get_data_entry(&"Items", p_key)
		var stats: StatsData = data.get_stats()
		_update_party_member_stats(p_pm_key, stats, true)
	args[p_group] = p_key
	
	var instance: Node = get_party_member_object(p_pm_key)
	instance.comph().call_comp("Equipment", &"equip", [p_group, p_key])

func unequip_party_member(p_pm_key: StringName, p_group: StringName) -> void:
	var args: Dictionary = _a_party_members[p_pm_key][&"Equipables"]
	var key: StringName = args[p_group]
	if key != &"":
		var data: EquipableData = Databases.get_data_entry(&"Items", key)
		var stats: StatsData = data.get_stats()
		_update_party_member_stats(p_pm_key, stats, false)
	args[p_group] = &""
	
	if p_group != &"Weapon" && p_group != &"Shield":
		var instance: Node = get_party_member_object(p_pm_key)
		instance.comph().call_comp("Equipment", &"unequip", [p_group])

func restore_all_party_members_HP() -> void:
	for key: StringName in _a_party_members:
		var stats: Dictionary = _a_party_members[key][&"Stats"]
		set_party_member_stat(key, &"HP", stats[&"Max_HP"])

func restore_all_party_members_SP() -> void:
	for key: StringName in _a_party_members:
		var stats: Dictionary = _a_party_members[key][&"Stats"]
		set_party_member_stat(key, &"SP", stats[&"Max_SP"])

func change_item_amount(p_key: StringName, p_amount: int) -> void:
	var data: ItemData = Databases.get_data_entry(&"Items", p_key)
	var type: StringName = data.get_type()
	var group: StringName = data.get_group()
	
	if !_a_inventory[type][group].has(p_key):
		_a_inventory[type][group][p_key] = {}
		var item: Dictionary = _a_inventory[type][group][p_key]
		item[&"Amount"] = 0
	
	var item_args: Dictionary = _a_inventory[type][group][p_key]
	var curr_amount: int = item_args[&"Amount"]
	var stack: int = data.get_stack_()
	item_args[&"Amount"] += p_amount
	item_args[&"Amount"] = min(item_args[&"Amount"], stack)
	item_args[&"Amount"] = max(item_args[&"Amount"], 0)
	var new_amount: int = item_args[&"Amount"]
	var diff: int = new_amount - curr_amount
	
	if item_args[&"Amount"] == 0:
		_a_inventory[type][group].erase(p_key)
	
	item_amount_changed.emit(p_key, new_amount, diff)

func change_coins_amount(p_amount: int) -> void:
	_a_coins += p_amount
	_a_coins = max(0, _a_coins)

func seconds_to_string(p_seconds: int) -> String:
	var hours: int = floor(p_seconds / 3600.0)
	p_seconds -= hours * 3600
	var minutes: int = floor(p_seconds / 60.0)
	p_seconds -= minutes * 60
	var seconds: int = p_seconds
	
	var hours_str: String = str(hours).pad_zeros(2)
	var minutes_str: String = str(minutes).pad_zeros(2)
	var seconds_str: String = str(seconds).pad_zeros(2)
	var text = "%s:%s:%s" % [hours_str, minutes_str, seconds_str]
	
	return text

func date_to_string(p_date: Dictionary) -> String:
	var year: String = str(p_date[&"Year"])
	var month: String = str(p_date[&"Month"]).pad_zeros(2)
	var day: String = str(p_date[&"Day"]).pad_zeros(2)
	var text: String = "%s.%s.%s" % [day, month, year]
	
	return text

func convert_trans_type_key(p_trans_type_key: StringName) -> Tween.TransitionType:
	match p_trans_type_key:
		&"Linear": return Tween.TRANS_LINEAR
		&"Sine": return Tween.TRANS_SINE
		&"Quint": return Tween.TRANS_QUINT
		&"Quart": return Tween.TRANS_QUART
		&"Quad": return Tween.TRANS_QUAD
		&"Expo": return Tween.TRANS_EXPO
		&"Elastic": return Tween.TRANS_ELASTIC
		&"Cubic": return Tween.TRANS_CUBIC
		&"Circ": return Tween.TRANS_CIRC
		&"Bounce": return Tween.TRANS_BOUNCE
		&"Back": return Tween.TRANS_BACK
	
	return Tween.TRANS_LINEAR

func convert_ease_type_key(p_ease_type_key: StringName) -> Tween.EaseType:
	match p_ease_type_key:
		&"In": return Tween.EASE_IN
		&"Out": return Tween.EASE_OUT
		&"In_Out": return Tween.EASE_IN_OUT
		&"Out_In": return Tween.EASE_OUT_IN
	
	return Tween.EASE_IN

func roll_loot(p_loot: Dictionary) -> Dictionary[StringName, int]:
	var rolled_loot: Dictionary[StringName, int] = {} # Match item_key to amount
	var loot_RNG: DicRNG = DicRNG.new()
	for item_key: StringName in p_loot:
		var item_dic: Dictionary[int, int]; item_dic.assign(p_loot[item_key])
		loot_RNG.set_dic(item_dic)
		
		var amount: int = loot_RNG.roll_key()
		rolled_loot[item_key] = amount
	
	return rolled_loot

func _update_joy() -> void:
	var connected: Array[int] = Input.get_connected_joypads()
	_a_use_joy = connected.size() > 0
	_a_joy_connected = _a_use_joy
	
	if _a_joy_connected:
		var joy_name: String = Input.get_joy_name(connected[0])
		_a_joy_type = _get_joy_type(joy_name)
	else:
		_a_joy_type = &""

func _create_save_dirs() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	for i: int in range(1, 4):
		var path: String = "%s%s" % [_a_SAVES_PATH, str(i)]
		if !FileAccess.file_exists(path):
			dir.make_dir_recursive(path)

func _validate_saved_data() -> void:
	var version: StringName = _a_saved_data[&"Version"]
	var curr_version: StringName = get_version()
	while version != curr_version:
		match version:
			&"0.0.6":
				_validate_006_to_007()
				version = &"0.0.7"
	
	_a_saved_data[&"Version"] = curr_version

func _validate_006_to_007() -> void:
	pass

func _init_party_members() -> void:
	var pm_data: Dictionary = Databases.get_data(&"Party_Members")
	for key: StringName in pm_data:
		var args: PartyMemberData = pm_data[key]
		_a_party_members[key] = {}
		_a_party_members[key][&"Active"] = false
		
		# Stats
		var stats: StatsData = args.get_stats()
		_a_party_members[key][&"Stats"] = {}
		var stats_args: Dictionary = _a_party_members[key][&"Stats"]
		stats_args[&"Max_HP"] = stats.get_max_HP()
		stats_args[&"HP"] = stats.get_HP()
		stats_args[&"Max_SP"] = stats.get_max_SP()
		stats_args[&"SP"] = stats.get_SP()
		stats_args[&"ATK"] = stats.get_ATK()
		stats_args[&"MAG"] = stats.get_MAG()
		stats_args[&"DEF"] = stats.get_DEF()
		stats_args[&"SPEED"] = stats.get_SPEED()
		stats_args[&"LUCK"] = stats.get_LUCK()
		
		# Progress
		_a_party_members[key][&"Progress"] = {}
		var progress_args: Dictionary = _a_party_members[key][&"Progress"]
		progress_args[&"Lvl"] = 1
		progress_args[&"Exp"] = 0
		
		# Equipables
		_a_party_members[key][&"Equipables"] = {}
		var equipables_args: Dictionary = _a_party_members[key][&"Equipables"]
		equipables_args[&"Head"] = &""
		equipables_args[&"Torso"] = &""
		equipables_args[&"Legs"] = &""
		equipables_args[&"Feet"] = &""
		equipables_args[&"Weapon"] = &""
		equipables_args[&"Shield"] = &""
		
		# Actions
		_a_party_members[key][&"Actions"] = {}
		var actions_args: Dictionary = _a_party_members[key][&"Actions"]
		# Commands
		actions_args[&"Commands"] = {}
		var commands: Dictionary = args.get_commands()
		for command_key: StringName in commands:
			var enabled: bool = commands[command_key]
			if enabled:
				actions_args[&"Commands"][command_key] = &"Enabled"
			else:
				actions_args[&"Commands"][command_key] = &"Disabled"
		
		# Specials
		actions_args[&"Specials"] = {}
		var specials: Dictionary = args.get_specials()
		for special_key: StringName in specials:
			var enabled: bool = specials[special_key]
			if enabled:
				actions_args[&"Specials"][special_key] = &"Enabled"
			else:
				actions_args[&"Specials"][special_key] = &"Disabled"

func _init_inventory() -> void:
	_a_inventory[&"General"] = {}
	_a_inventory[&"General"][&"Main"] = {}
	_a_inventory[&"Key"] = {}
	_a_inventory[&"Key"][&"Main"] = {}
	_a_inventory[&"Equipment"] = {}
	for group: StringName in _a_EQUIPMENT_GROUPS:
		_a_inventory[&"Equipment"][group] = {}

func _init_for_loop_idxs() -> void:
	for i: int in range(97, 123):
		a_for_loop_idxs[char(i)] = null

func init_camera_limit() -> void:
	_a_camera_limit[SIDE_LEFT] = -10000000
	_a_camera_limit[SIDE_TOP] = -10000000
	_a_camera_limit[SIDE_RIGHT] = 10000000
	_a_camera_limit[SIDE_BOTTOM] = 10000000

func _init_saved_data() -> void:
	_a_saved_data[&"Maps"] = {}
	_a_saved_data[&"Singletons"] = {}
	_a_saved_data[&"Singletons"][&"Audio_Manager"] = {}
	_a_saved_data[&"Singletons"][&"Dialogue_System"] = {}
	_a_saved_data[&"Singletons"][&"Cutscene_System"] = {}
	_a_saved_data[&"Singletons"][&"Progress"] = {}
	_a_saved_data[&"Singletons"][&"Main_Menu"] = {}

func grid_point_to_pos(p_point: Variant, p_grid_step: Variant, p_grid_start: Variant) -> Variant:
	if p_point is Vector2:
		return grid_point_to_pos_2D(p_point, p_grid_step, p_grid_start)
	elif p_point is Vector3:
		return grid_point_to_pos_3D(p_point, p_grid_step, p_grid_start)
	
	return null

func grid_point_to_pos_2D(p_point: Vector2, p_grid_step: Vector2, p_grid_start: Vector2) -> Vector2:
	var half_offset: Vector2 = p_grid_step / 2.0
	var pos: Vector2 = p_grid_start + (p_point * p_grid_step) + half_offset
	
	return pos

func grid_point_to_pos_3D(p_point: Vector3, p_grid_step: Vector3, p_grid_start: Vector3) -> Vector3:
	var half_offset: Vector3 = Vector3(p_grid_step.x / 2.0, 0.0, p_grid_step.z / 2.0)
	var pos: Vector3 = p_grid_start + (p_point * p_grid_step) + half_offset
	
	return pos

func pos_to_grid_point(p_pos: Variant, p_grid_step: Variant, p_grid_start: Variant) -> Variant:
	if p_pos is Vector2:
		return pos_to_grid_point_2D(p_pos, p_grid_step, p_grid_start)
	elif p_pos is Vector3:
		return pos_to_grid_point_3D(p_pos, p_grid_step, p_grid_start)
	
	return null

func pos_to_grid_point_2D(p_pos: Vector2, p_grid_step: Vector2, p_grid_start: Vector2) -> Vector2:
	var point: Vector2 = Vector2.ZERO
	point.x = floor((p_pos.x - p_grid_start.x) / p_grid_step.x)
	point.y = floor((p_pos.y - p_grid_start.y) / p_grid_step.y)
	
	return point

func pos_to_grid_point_3D(p_pos: Vector3, p_grid_step: Vector3, p_grid_start: Vector3) -> Vector3:
	var point: Vector3 = Vector3.ZERO
	point.x = floor((p_pos.x - p_grid_start.x) / p_grid_step.x)
	point.y = floor((p_pos.y - p_grid_start.y) / p_grid_step.y)
	point.z = floor((p_pos.z - p_grid_start.z) / p_grid_step.z)
	
	return point

func get_screen_pos_3D(p_screen_pos: Vector2, p_camera: Camera3D, p_collision_mask: int) -> Vector3:
	var ray_from: Vector3 = p_camera.project_ray_origin(p_screen_pos)
	var ray_to: Vector3 = ray_from + p_camera.project_ray_normal(p_screen_pos) * 2000.0
	var world_3d: World3D = p_camera.get_world_3d()
	var space_state: PhysicsDirectSpaceState3D = world_3d.get_direct_space_state()
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to, p_collision_mask)
	query.set_collide_with_bodies(true)
	query.set_collide_with_areas(true)
	
	var res: Dictionary = space_state.intersect_ray(query)
	return res.get(&"position", null)

func get_default_cursor() -> Texture2D:
	return _a_Default_Cursor

func get_version() -> StringName:
	return _e_version

func get_save_path() -> String:
	return _a_SAVE_PATH

func get_title_screen_scene_path() -> String:
	return _a_TITLE_SCREEN_SCENE_PATH

func get_item_type_icon_path() -> String:
	return _a_ITEM_TYPE_ICON_PATH

func get_item_path() -> String:
	return _a_ITEM_PATH

func get_popup_path() -> String:
	return _a_POPUP_PATH

func get_popup_types() -> Array[StringName]:
	return _a_POPUP_TYPES

func get_equipment_groups() -> Array[StringName]:
	return _a_EQUIPMENT_GROUPS

func get_layouts() -> Array[StringName]:
	return _a_LAYOUTS

func get_party_member_equipable(p_pm_key: StringName, p_group: StringName) -> StringName:
	return _a_party_members[p_pm_key][&"Equipables"][p_group]

func set_party_member_stat(p_key: StringName, p_stat: StringName, p_value: int) -> void:
	var stats: Dictionary = _a_party_members[p_key][&"Stats"]
	match p_stat:
		&"HP":
			var max_HP: int = stats[&"Max_HP"]
			stats[&"HP"] = p_value
			stats[&"HP"] = min(stats[&"HP"], max_HP)
			stats[&"HP"] = max(stats[&"HP"], 0)
		&"SP":
			var max_SP: int = stats[&"Max_SP"]
			stats[&"SP"] = p_value
			stats[&"SP"] = min(stats[&"SP"], max_SP)
			stats[&"SP"] = max(stats[&"SP"], 0)
		&"Max_HP":
			stats[&"Max_HP"] = max(p_value, 0)
			stats[&"HP"] = min(stats[&"HP"], stats[&"Max_HP"])
		&"Max_SP":
			stats[&"Max_SP"] = max(p_value, 0)
			stats[&"SP"] = min(stats[&"SP"], stats[&"Max_SP"])
		_:
			stats[p_stat] = max(p_value, 0)
	
	pm_stat_changed.emit(p_key, p_stat, stats[p_stat])

func get_party_member_stat(p_key: StringName, p_stat: StringName) -> int:
	return _a_party_members[p_key][&"Stats"][p_stat]

func has_item(p_key: StringName, p_min: int = 1, p_max: int = -1) -> bool:
	var amount: int = get_item_amount(p_key)
	if p_min == -1 || amount >= p_min:
		if p_max == -1 || amount <= p_max:
			return true
	
	return false

func get_item_amount(p_key: StringName) -> int:
	var data: ItemData = Databases.get_data_entry(&"Items", p_key)
	var type: StringName = data.get_type()
	var group: StringName = data.get_group()
	var amount: int = 0
	if _a_inventory[type][group].has(p_key):
		var item: Dictionary = _a_inventory[type][group][p_key]
		amount = item[&"Amount"]
	
	return amount

func set_play_time(p_play_time: int) -> void:
	_a_play_time = p_play_time

func get_play_time() -> int:
	return _a_play_time

func set_party_members(p_party_members: Dictionary) -> void:
	_a_party_members = p_party_members

func get_party_members() -> Dictionary:
	return _a_party_members

func get_party_members_active() -> Dictionary:
	var party_members_active: Dictionary = {}
	for key: StringName in _a_party_members:
		var args: Dictionary = _a_party_members[key]
		var active: bool = args[&"Active"]
		if active:
			party_members_active[key] = args
	
	return party_members_active

func set_inventory(p_inventory: Dictionary) -> void:
	_a_inventory = p_inventory

func get_inventory() -> Dictionary:
	return _a_inventory

func get_coins() -> int:
	return _a_coins

func get_base_vp_size() -> Vector2i:
	return _a_base_vp_size

func set_camera_limit(p_camera_limit: Dictionary[Side, float]) -> void:
	for side: Side in p_camera_limit:
		set_camera_limit_side(side, p_camera_limit[side])

func get_camera_limit() -> Dictionary[Side, float]:
	return _a_camera_limit

func set_camera_limit_side(p_side: Side, p_limit: float) -> void:
	_a_camera_limit[p_side] = p_limit
	if is_instance_valid(_a_curr_camera):
		_a_curr_camera.set_limit(p_side, p_limit)

func get_layout_pos(p_size: Vector2, p_vp_size: Vector2i, p_layout: StringName, p_margin: int) -> Vector2:
	var pos: Vector2
	match p_layout:
		&"Top_Left":
			pos = Vector2(p_margin, p_margin)
		&"Top_Right":
			pos = Vector2(p_vp_size.x, 0.0)
			pos.x -= p_size.x
			pos += Vector2(-p_margin, p_margin)
		&"Bottom_Right":
			pos = Vector2(p_vp_size)
			pos -= p_size
			pos -= Vector2(p_margin, p_margin)
		&"Bottom_Left":
			pos = Vector2(0.0, p_vp_size.y)
			pos.y -= p_size.y
			pos += Vector2(p_margin, -p_margin)
		&"Center_Left":
			pos = Vector2(0.0, p_vp_size.y / 2.0)
			pos.y -= p_size.y / 2.0
			pos.x += p_margin
		&"Center_Top":
			pos = Vector2(p_vp_size.x / 2.0, 0.0)
			pos.x -= p_size.x / 2.0
			pos.y += p_margin
		&"Center_Right":
			pos = Vector2(p_vp_size.x, p_vp_size.y / 2.0)
			pos -= Vector2(p_size.x, p_size.y / 2.0)
			pos.x -= p_margin
		&"Center_Bottom":
			pos = Vector2(p_vp_size.x / 2.0, p_vp_size.y)
			pos -= Vector2(p_size.x / 2.0, p_size.y)
			pos.y -= p_margin
		&"Center":
			pos = Vector2(p_vp_size) / 2.0
			pos -= p_size / 2.0
	
	return pos

func get_text_color_for_bg(p_bg_color: Color) -> Color:
	var r_weighted: float = 0.241 * p_bg_color.r8**2
	var g_weighted: float = 0.691 * p_bg_color.g8**2
	var b_weighted: float = 0.068 * p_bg_color.b8**2
	var brightness: float = sqrt(r_weighted + g_weighted + b_weighted)
	if brightness < 130.0:
		return Color.WHITE
	else:
		return Color.BLACK

func get_dir_to_pos(p_from: Variant, p_to: Variant) -> StringName:
	var diff: Variant = p_to - p_from
	var dir: StringName = get_vec_dir(diff)
	
	return dir

func get_vec_dir(p_vec: Variant) -> StringName:
	var ordinate: float
	if p_vec is Vector2: ordinate = p_vec.y
	elif p_vec is Vector3: ordinate = p_vec.z
	
	if abs(p_vec.x) > abs(ordinate):
		if p_vec.x < 0.0:
			return &"Left"
		else:
			return &"Right"
	else:
		if ordinate < 0.0:
			return &"Up"
		else:
			return &"Down"

func get_dir_rotation_deg(p_dir: StringName) -> Vector3:
	match p_dir:
		&"Down": return Vector3(0.0, 0.0, 0.0)
		&"Left": return Vector3(0.0, -90.0, 0.0)
		&"Right": return Vector3(0.0, 90.0, 0.0)
		&"Up": return Vector3(0.0, 180.0, 0.0)
	
	return Vector3.ZERO

func get_opposite_dir(p_dir: StringName) -> StringName:
	match p_dir:
		&"Down": return &"Up"
		&"Left": return &"Right"
		&"Right": return &"Left"
		&"Up": return &"Down"
	
	return ""

func get_dir_rotated(p_dir: StringName, p_degrees: float) -> StringName:
	var dirs: Array[StringName] = [&"Up", &"Right", &"Down", &"Left"]
	var dir_idx: int = dirs.find(p_dir)
	var offset: int = int(snappedf(p_degrees, 45.0) / 90.0)
	var new_idx: int = (dir_idx + offset) % 4
	var dir: StringName = dirs[new_idx]
	
	return dir

func get_rndm_dir(p_excluded: StringName = &"") -> StringName:
	var dirs: Array[StringName] = [&"Down", &"Left", &"Right", &"Up"]
	if !p_excluded.is_empty():
		dirs.erase(p_excluded)
	var idx: int = randi() % dirs.size()
	var dir: StringName = dirs[idx]
	
	return dir

func get_rndm_point_circle(p_min_radius: float, p_max_radius: float) -> Vector2:
	var r2_max: float = p_max_radius**2
	var r2_min: float = p_min_radius**2
	var r: float = sqrt(randf() * (r2_max - r2_min) + r2_min)
	var t: float = randf() * TAU
	return Vector2(r, 0).rotated(t)

func get_nodes_in_group_vp(p_vp: Viewport, p_group: StringName) -> Array[Node]:
	var nodes: Array[Node] = []
	var instances: Array[Node] = get_tree().get_nodes_in_group(p_group)
	for instance: Node in instances:
		var vp: Viewport = instance.get_viewport()
		if vp == p_vp:
			nodes.push_back(instance)
	
	return nodes

func get_objects_vp(p_vp: Viewport, p_needed_comps: Array[String] = [],
					p_allowed_classes: Array[String] = ["Node"]) -> Array[Node]:
	var objects: Array[Node] = []
	var instances: Array[Node] = get_tree().get_nodes_in_group(&"Object")
	for instance: Node in instances:
		var vp: Viewport = instance.get_viewport()
		if vp != p_vp:
			continue
		
		var has_comps: bool = true
		for comp: String in p_needed_comps:
			if !instance.comph().has_comp(comp):
				has_comps = false
				break
		
		var class_allowed: bool = false
		for class_: String in p_allowed_classes:
			if instance.is_class(class_):
				class_allowed = true
				break
		
		if has_comps && class_allowed:
			objects.push_back(instance)
	
	return objects

func get_object(p_key: StringName, p_needed_comps: Array[String] = []) -> Node:
	p_needed_comps.push_back("Reference")
	var viewport: Viewport = get_viewport()
	var instances: Array[Node] = get_objects_vp(viewport, p_needed_comps)
	for instance: Node in instances:
		var key: StringName = instance.comph().call_comp("Reference", &"get_key")
		if key == p_key:
			return instance
	
	return null

func get_all_objects(p_needed_comps: Array[String] = []) -> Array[Node]:
	var viewport: Viewport = get_viewport()
	var instances: Array[Node] = get_objects_vp(viewport, p_needed_comps)
	
	return instances

func get_party_member_object(p_pm_key: StringName) -> Node:
	var viewport: Viewport = get_viewport()
	var instances: Array[Node] = get_objects_vp(viewport, ["Party_Member"])
	for instance: Node in instances:
		var pm_key: StringName = instance.comph().call_comp("Party_Member", &"get_pm_key")
		if pm_key == p_pm_key:
			return instance
	
	return null

func get_singleton(p_caller: Node, p_name: String) -> Node:
	var root: Window = get_tree().get_root()
	var vp: Viewport = p_caller.get_viewport()
	while vp != root && !vp.is_sub_world():
		vp = _get_closest_vp(vp)
	var singleton: Node = vp.get_node(p_name)
	
	return singleton

func get_saved_map_data() -> Dictionary:
	var scene_manager_si: Scene_Manager = get_singleton(self, "Scene_Manager")
	var location: StringName = scene_manager_si.get_location()
	var data: Dictionary = {}
	if _a_saved_data[&"Maps"].has(location):
		data = _a_saved_data[&"Maps"][location]
	
	return data

func set_player(p_instance: Node) -> void:
	_a_player = p_instance

func get_player() -> Node:
	return _a_player

func set_curr_camera(p_camera: Node) -> void:
	_a_curr_camera = p_camera
	for side: Side in _a_camera_limit:
		var limit: float = _a_camera_limit[side]
		p_camera.set_limit(side, limit)
	p_camera.make_current_()
	
	curr_camera_changed.emit(p_camera)

func get_curr_camera() -> Node:
	return _a_curr_camera

func get_trans_anim_pos() -> float:
	return _a_Trans_Anims.get_current_animation_position()

func get_use_joy() -> bool:
	return _a_use_joy

func get_joy_type() -> StringName:
	return _a_joy_type

func get_time_text(p_hours: int, p_minutes: int) -> String:
	var hours_text: String = str(p_hours).pad_zeros(2)
	var minutes_text: String = str(p_minutes).pad_zeros(2)
	var time_text: String = "%s:%s" % [hours_text, minutes_text]
	
	return time_text

func get_date_text(p_year: int, p_month: int, p_day: int) -> String:
	var year_text: String = str(p_year)
	var month_text: String = str(p_month).pad_zeros(2)
	var day_text: String = str(p_day).pad_zeros(2)
	var date_text: String = "%s.%s.%s" % [day_text, month_text, year_text]
	
	return date_text

func get_tutato_explain(p_key: StringName) -> ObjectTutatoCompExplainBase2D:
	return _a_Tutato.comph().get_comp(p_key)

func has_trans_anim(p_name: StringName) -> bool:
	return _a_Trans_Anims.has_animation(p_name)

func is_paused() -> bool:
	return _a_paused > 0

func is_bit_enabled(p_mask: int, p_idx: int) -> bool:
	return p_mask & (1 << p_idx) != 0

func is_instance_in_game_world(p_instance: Node) -> bool:
	var vp: Viewport = p_instance.get_viewport()
	var root: Window = get_tree().get_root()
	return vp == root || vp.is_game_world()

func _get_closest_vp(p_vp: Viewport) -> Viewport:
	var vp: Viewport = get_tree().get_root()
	if p_vp == vp:
		return p_vp
	
	var parent: Node = p_vp.get_parent()
	vp = parent.get_viewport()
	
	return vp

func _get_joy_type(p_joy_name: StringName) -> StringName:
	if "XBox Controller" in p_joy_name || "Steam Controller" in p_joy_name:
		return &"Joy_Letters_Color"
	if ("PlayStation Controller" in p_joy_name ||
		"PlayStation Classic Controller" in p_joy_name ||
		"PlayStation Vita" in p_joy_name):
		return &"Joy_Shapes_Color"
	return &"Joy_Letters_Neutral"
	#if ("Switch Controller" in p_joy_name ||
		#"Switch Pro Controller" in p_joy_name ||
		#"Wii U Pro Controller" in p_joy_name ||
		#"Steam Deck" in p_joy_name):
		#return "Joy_Letters_Neutral"

func save_data(p_for_file: bool) -> void:
	# MAP
	var scene_manager_si: Scene_Manager = get_singleton(self, "Scene_Manager")
	var location: StringName = scene_manager_si.get_location()
	var scene_instance: Node = scene_manager_si.get_curr_scene_instance()
	var maps_data: Dictionary = _a_saved_data[&"Maps"]
	maps_data[location] = {}
	maps_data[location][&"Curr_Scene"] = scene_instance.get_save_data()
	maps_data[location][&"Objects"] = {}
	
	var viewport: Viewport = get_viewport()
	var instances: Array[Node] = get_objects_vp(viewport, ["Save"])
	for instance: Node in instances:
		instance.comph().call_comp("Save", &"save_data", [maps_data[location]])
	# ------------------
	
	# SINGLETONS
	var audio_manager_si: Audio_Manager = get_singleton(self, "Audio_Manager")
	var cutscene_system_si: Cutscene_System = get_singleton(self, "Cutscene_System")
	var dialogue_system_si: Dialogue_System = get_singleton(self, "Dialogue_System")
	var progress_si: Progress = get_singleton(self, "Progress")
	var main_menu_si: Main_Menu = get_singleton(self, "Main_Menu")
	var si_data: Dictionary = _a_saved_data[&"Singletons"]
	si_data[&"Audio_Manager"] = audio_manager_si.get_save_data(location)
	si_data[&"Cutscene_System"] = cutscene_system_si.get_save_data(location, p_for_file)
	si_data[&"Dialogue_System"] = dialogue_system_si.get_save_data(location, p_for_file)
	si_data[&"Progress"] = progress_si.get_save_data()
	si_data[&"Main_Menu"] = main_menu_si.get_save_data()
	si_data[&"Scene_Manager"] = scene_manager_si.get_save_data()
	# ------------------

func save_file_data(p_idx: int) -> void:
	_a_saved_data[&"Singletons"][&"Global"] = _get_save_file_data()
	_a_saved_data[&"Version"] = get_version()
	save_data(true)
	
	Global_Data.set_save_file_idx(p_idx)
	Global_Data.save_data()
	
	var path: String = _a_SAVE_PATH % p_idx
	Data_Parser.write_var_data(path, _a_saved_data)

func load_file_data(p_idx: int) -> void:
	var path: String = _a_SAVE_PATH % p_idx
	_a_saved_data = Data_Parser.load_var_data(path)
	
	_validate_saved_data()
	
	var data: Dictionary = _a_saved_data[&"Singletons"][&"Global"]
	_a_play_time = data[&"Play_Time"]
	_a_party_members = data[&"Party_Members"]
	_a_inventory = data[&"Inventory"]
	_a_coins = data[&"Coins"]
	a_for_loop_idxs = data[&"For_Loop_Idxs"]
	
	var audio_manager_si: Audio_Manager = get_singleton(self, "Audio_Manager")
	var dialogue_system_si: Dialogue_System = get_singleton(self, "Dialogue_System")
	var cutscene_system_si: Cutscene_System = get_singleton(self, "Cutscene_System")
	var progress_si: Progress = get_singleton(self, "Progress")
	var main_menu_si: Main_Menu = get_singleton(self, "Main_Menu")
	var scene_manager_si: Scene_Manager = get_singleton(self, "Scene_Manager")
	var si_data: Dictionary = _a_saved_data[&"Singletons"]
	audio_manager_si.load_file_data(si_data[&"Audio_Manager"])
	cutscene_system_si.load_file_data(si_data[&"Cutscene_System"])
	dialogue_system_si.load_file_data(si_data[&"Dialogue_System"])
	progress_si.load_file_data(si_data[&"Progress"])
	main_menu_si.load_file_data(si_data[&"Main_Menu"])
	scene_manager_si.load_file_data(si_data[&"Scene_Manager"])
	
	Global_Data.set_save_file_idx(p_idx)
	Global_Data.save_data()
	
	_a_Play_Time.start()

func _get_save_file_data() -> Dictionary:
	var date: Dictionary = Time.get_date_dict_from_system()
	var data: Dictionary = {}
	data[&"Play_Time"] = _a_play_time
	data[&"Date"] = {}
	data[&"Date"][&"Year"] = date[&"year"]
	data[&"Date"][&"Month"] = date[&"month"]
	data[&"Date"][&"Day"] = date[&"day"]
	data[&"Party_Members"] = _a_party_members
	data[&"Inventory"] = _a_inventory
	data[&"Coins"] = _a_coins
	data[&"For_Loop_Idxs"] = a_for_loop_idxs
	
	return data

func load_data(p_for_file: bool) -> void:
	var scene_manager_si: Scene_Manager = get_singleton(self, "Scene_Manager")
	var audio_manager_si: Audio_Manager = get_singleton(self, "Audio_Manager")
	var cutscene_system_si: Cutscene_System = get_singleton(self, "Cutscene_System")
	cutscene_system_si.data_loaded.connect(_on_Cutscene_System_data_loaded)
	
	var location: StringName = scene_manager_si.get_location()
	audio_manager_si.load_data(location)
	cutscene_system_si.load_data(location, p_for_file)

func _on_Play_Time_timeout() -> void:
	_a_play_time += 1

func _on_Trans_Anims_anim_finished(_p_name: StringName) -> void:
	trans_finished.emit()

func _on_joy_connection_changed(_p_device: int, _p_connected: bool) -> void:
	_update_joy()

func _on_Cutscene_System_data_loaded() -> void:
	var scene_manager_si: Scene_Manager = get_singleton(self, "Scene_Manager")
	var cutscene_system_si: Cutscene_System = get_singleton(self, "Cutscene_System")
	var dialogue_system_si: Dialogue_System = get_singleton(self, "Dialogue_System")
	cutscene_system_si.data_loaded.disconnect(_on_Cutscene_System_data_loaded)
	
	var location: StringName = scene_manager_si.get_location()
	dialogue_system_si.load_data(location)

func sort_low(p_a: Variant, p_b: Variant) -> bool:
	return p_a[0] < p_b[0]

func sort_high(p_a: Variant, p_b: Variant) -> bool:
	return p_a[0] > p_b[0]
