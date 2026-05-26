extends Node3D
class_name SVEncounterBase

signal battle_ended(p_location: StringName, p_res: StringName)

@export var _e_BGM: FWAudioPlayback = null
@export var _e_BGS: Array[FWAudioPlayback] = []
@export var _e_pm_comps: Array[PackedScene] = []

const _a_PARTY_MEMBER_SCENE_PATH: String = "res://Global_Scenes/Battle_System/SV_Battle/Party_Members/%s/%s.tscn"
const _a_ENEMY_SCENE_PATH: String = "res://Global_Scenes/Battle_System/SV_Battle/Enemies/%s/%s.tscn"
const _a_COMMAND_LOC_ID: String = "SV_ACTIONS_%s"

var _a_Popup_Scene: PackedScene = preload("uid://d4mam0acvnt2")

@onready var _a_Free_Camera: FWNode3DObject = get_node("Objects/$Free_Camera")
@onready var _a_Free_Audio: FWPausableAudio3D = get_node("Objects/$Free_Audio")
@onready var _a_Party_Members_Place_Pos: SVEncounterPlacePos = get_node("Objects/Party_Members/Place_Pos")
@onready var _a_Party_Members_Instances: Node3D = get_node("Objects/Party_Members/Instances")
@onready var _a_Enemies_Place_Pos: SVEncounterPlacePos = get_node("Objects/Enemies/Place_Pos")
@onready var _a_Enemies_Instances: Node3D = get_node("Objects/Enemies/Instances")
@onready var _a_Popups: Node3D = get_node("Objects/Popups")
@onready var _a_Flee_Pos: Marker3D = get_node("Flee_Pos")
@onready var _a_Command_Circle: SVEncounterCommandCircle = get_node("Command_Circle")
@onready var _a_Rating: SVEncounterRating = get_node("Rating")
@onready var _a_Indicators: SVEncounterIndicators = get_node("Indicators")
@onready var _a_Enemy_Select: SVEncounterEnemySelect = get_node("Enemy_Select")
@onready var _a_Specials_Menu: SVEncounterSpecialsMenu = get_node("Canvas/Specials_Menu")
@onready var _a_Speedlines: ColorRect = get_node("Canvas/Speedlines")
@onready var _a_Stats_Display: StatsDisplayBattle = get_node("Canvas/Stats_Display")

var _a_map_res: BattleSV.MAP_RES # Result of how the battle started on map
var _a_troop: Array[StringName] # Enemy keys
var _a_bonus_loot: Dictionary # Loot from map that will definitely be obtained
var _a_special: bool # Special battles have a predefined troop
var _a_order: Array[StringName] = [] # Attack order of battlers
var _a_order_idx: int = -1 # Current idx of _a_order
var _a_instance: SVCharacter = null # Currently active battler
var _a_battle_ended: bool = false # Has battle ended?

var _a_characters: Dictionary[StringName, SVCharacter] = {} # Match key to instance
var _a_party_members: Dictionary[StringName, SVPartyMember] = {} # Match party member key to instance
var _a_enemies: Dictionary[StringName, SVEnemy] = {} # Match enemy key to instance
var _a_characters_alive: Dictionary[StringName, SVCharacter] = {} # Match key to instance
var _a_party_members_alive: Dictionary[StringName, SVPartyMember] = {} # Match key to instance
var _a_enemies_alive: Dictionary[StringName, SVEnemy] = {} # Match key to instance

func _ready() -> void:
	_a_Command_Circle.changed.connect(_on_Command_Circle_changed)
	_a_Command_Circle.selected.connect(_on_Command_Circle_selected)
	_a_Enemy_Select.changed.connect(_on_Enemy_Select_changed)
	_a_Enemy_Select.selected.connect(_on_Enemy_Select_selected)
	_a_Enemy_Select.canceled.connect(_on_Enemy_Select_canceled)
	_a_Specials_Menu.selected.connect(_on_Specials_Menu_selected)
	_a_Specials_Menu.canceled.connect(_on_Specials_Menu_canceled)
	
	var global_si: Global = Global.get_singleton(self, "Global")
	var camera_comp: FWCompCamera3D = _a_Free_Camera.comph().get_comp("Camera")
	global_si.init_camera_limit()
	global_si.set_curr_camera(camera_comp)
	
	if !Global.is_instance_in_game_world(self):
		return
	
	_play_BGM()
	_play_BGS()

func instantiate_popup(p_type: StringName, p_to: SVCharacter, p_text: String) -> void:
	var instance: BattlePopup = _a_Popup_Scene.instantiate()
	instance.set_text.call_deferred(p_text)
	match p_type:
		&"Damage": instance.set_modulate.call_deferred(Battle_System.a_DAMAGE_COLOR)
		&"Heal": instance.set_modulate.call_deferred(Battle_System.a_HEAL_COLOR)
	
	var pos: Vector3 = p_to.get_global_position()
	var offset: Vector3 = p_to.get_popup_offset()
	_a_Popups.add_child(instance)
	instance.set_global_position(pos + offset)

func deal_dmg_rating(p_from: SVPartyMember, p_to: SVEnemy) -> void:
	var rating: StringName = p_from.get_timing_rating()
	var dmg_fac: float = _get_pm_dmg_fac(rating)
	var from_ATK: int = p_from.comph().call_comp("Stats", &"get_curr_stat", [&"ATK"])
	var to_DEF: int = p_to.comph().call_comp("Stats", &"get_curr_stat", [&"DEF"])
	var ATK: int = int(round(from_ATK * dmg_fac))
	var dmg: int = ATK - to_DEF
	_deal_dmg(p_from, p_to, dmg)
	display_rating(p_to, rating)

func deal_dmg(p_from: SVCharacter, p_to: SVCharacter) -> void:
	var from_atk: int = p_from.comph().call_comp("Stats", &"get_curr_stat", [&"ATK"])
	var to_def: int = p_to.comph().call_comp("Stats", &"get_curr_stat", [&"DEF"])
	var dmg: int = from_atk - to_def
	_deal_dmg(p_from, p_to, dmg)

func _deal_dmg(p_from: SVCharacter, p_to: SVCharacter, p_dmg: int) -> void:
	instantiate_popup(&"Damage", p_to, str(p_dmg))
	
	var from_pos: Vector3 = p_from.get_global_position()
	var to_pos: Vector3 = p_to.get_global_position()
	var dir_vec: Vector3 = from_pos.direction_to(to_pos)
	p_to.process_dmg(p_dmg)
	_knockback(p_to, p_dmg, dir_vec)

func display_rating(p_instance: SVCharacter, p_rating: StringName) -> void:
	var pos: Vector3 = p_instance.get_global_position()
	var offset: Vector3 = p_instance.get_rating_offset()
	_a_Rating.display(pos + offset, p_rating)

func battle_end(p_res: StringName) -> void:
	_a_battle_ended = true
	
	# Change party member data based on stats after battle
	var global_si: Global = Global.get_singleton(self, "Global")
	for key: StringName in _a_party_members:
		var instance: SVPartyMember = _a_party_members[key]
		var HP: int = instance.comph().call_comp("Stats", &"get_curr_stat", [&"HP"])
		var SP: int = instance.comph().call_comp("Stats", &"get_curr_stat", [&"SP"])
		global_si.set_party_member_stat(key, &"HP", max(HP, 1))
		global_si.set_party_member_stat(key, &"SP", SP)
	
	var total_EXP: int = 0
	var total_loot: Dictionary[StringName, int] = {} # Match item_key to amount
	for instance: SVEnemy in _a_enemies.values():
		var EXP: int = instance.get_EXP()
		var loot: Dictionary = instance.get_loot()
		total_EXP += EXP
		_loot_to_total_loot(loot, total_loot)
	_loot_to_total_loot(_a_bonus_loot, total_loot)
	
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	var location: StringName = scene_manager_si.get_location()
	battle_ended.emit(location, p_res, total_EXP, total_loot)
	
	_a_Speedlines.hide()
	_a_Stats_Display.hide()

func battle() -> void:
	if !_a_special:
		_instantiate_party_members()
		_instantiate_enemies()
	_init_party_members()
	_init_enemies()
	
	_a_Stats_Display.open(_a_party_members)
	
	_update_order()
	_handle_map_res()

func _play_BGM() -> void:
	if _e_BGM == null:
		return
	
	var audio_manager_si: Audio_Manager = Global.get_singleton(self, "Audio_Manager")
	var stream: AudioStream = _e_BGM.get_stream()
	var volume: float = _e_BGM.get_volume()
	var pitch: float = _e_BGM.get_pitch()
	var from: float = _e_BGM.get_from()
	var player: FWPausableAudio = audio_manager_si.replace_bgm(stream, volume, pitch, from)
	audio_manager_si.flatten_bgm(player)

func _play_BGS() -> void:
	var audio_manager_si: Audio_Manager = Global.get_singleton(self, "Audio_Manager")
	var players: Array[AudioStreamPlayer] = []
	for BGS: FWAudioPlayback in _e_BGS:
		var stream: AudioStream = BGS.get_stream()
		var volume: float = BGS.get_volume()
		var pitch: float = BGS.get_pitch()
		var from: float = BGS.get_from()
		var player: AudioStreamPlayer = audio_manager_si.replace_bgs(stream, volume, pitch, from)
		players.push_back(player)
	audio_manager_si.flatten_bgs(players)

func _instantiate_party_members() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var party_members: Dictionary = global_si.get_party_members_active()
	var keys: Array[StringName]; keys.assign(party_members.keys())
	var amount: int = keys.size()
	var place_pos: Array[Vector3] = _a_Party_Members_Place_Pos.get_place_pos(amount)
	for i: int in amount:
		var key: StringName = keys[i]
		var path: String = _a_PARTY_MEMBER_SCENE_PATH % [key, key]
		var scene: PackedScene = load(path)
		var instance: SVPartyMember = scene.instantiate()
		var pos: Vector3 = place_pos[i]
		instance.set_position(pos)
		_a_Party_Members_Instances.add_child(instance)
		
		for comp_scene: PackedScene in _e_pm_comps:
			var comp_instance: Node = comp_scene.instantiate()
			instance.comph().add_comp(comp_instance)

func _instantiate_enemies() -> void:
	var amount: int = _a_troop.size()
	var place_pos: Array[Vector3] = _a_Enemies_Place_Pos.get_place_pos(amount)
	for i: int in amount:
		var enemy_key: StringName = _a_troop[i]
		var path: String = _a_ENEMY_SCENE_PATH % [enemy_key, enemy_key]
		var scene: PackedScene = load(path)
		var instance: SVEnemy = scene.instantiate()
		var pos: Vector3 = place_pos[i]
		instance.set_position(pos)
		_a_Enemies_Instances.add_child(instance)

func _init_party_members() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var party_members: Dictionary = global_si.get_party_members()
	for instance: SVPartyMember in _a_Party_Members_Instances.get_children():
		var key: StringName = instance.comph().call_comp("Party_Member", &"get_pm_key")
		var args: Dictionary = party_members[key]
		var stats: Dictionary[StringName, int]; stats.assign(args[&"Stats"])
		var actions: Dictionary = args[&"Actions"]
		instance.action_started.connect(_on_Character_action_started.bind(instance))
		instance.action_finished.connect(_on_Character_action_finished)
		instance.action_canceled.connect(_on_Character_action_canceled)
		instance.action_pre_event.connect(_on_Character_action_pre_event.bind(instance))
		instance.action_post_event.connect(_on_Character_action_post_event.bind(instance))
		instance.action_finished.connect(_on_Party_Member_action_finished.bind(instance))
		instance.hit.connect(_on_Party_Member_hit.bind(instance))
		instance.died.connect(_on_Party_Member_died.bind(key))
		instance.comph().call_comp("Stats", &"set_max_stat", [&"HP", stats[&"HP"]])
		instance.comph().call_comp("Stats", &"set_max_stat", [&"SP", stats[&"SP"]])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"HP", stats[&"HP"]])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"SP", stats[&"SP"]])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"ATK", stats[&"ATK"]])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"MAG", stats[&"MAG"]])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"DEF", stats[&"DEF"]])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"SPEED", stats[&"SPEED"]])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"LUCK", stats[&"LUCK"]])
		
		instance.set_encounter(self)
		instance.set_actions(actions)
		
		_a_characters[key] = instance
		_a_party_members[key] = instance
		_a_characters_alive[key] = instance
		_a_party_members_alive[key] = instance

func _init_enemies() -> void:
	var enemies_data: Dictionary[StringName, EnemyData]; enemies_data.assign(Databases.get_data(&"Enemies"))
	for i: int in _a_Enemies_Instances.get_child_count():
		var instance: SVEnemy = _a_Enemies_Instances.get_child(i)
		var enemy_key: StringName = instance.get_key()
		var key: StringName = "%s_%s" % [enemy_key, i]
		var args: EnemyData = enemies_data[enemy_key]
		var stats: EnemyStatsData = args.get_stats()
		var actions: Dictionary = args.get_actions()
		instance.action_finished.connect(_on_Character_action_finished)
		instance.action_canceled.connect(_on_Character_action_canceled)
		instance.action_pre_event.connect(_on_Character_action_pre_event.bind(instance))
		instance.action_post_event.connect(_on_Character_action_post_event.bind(instance))
		instance.action_reaction_started.connect(_on_Enemy_action_reaction_started)
		instance.action_reaction_finished.connect(_on_Enemy_action_reaction_finished)
		instance.hit.connect(_on_Enemy_hit.bind(instance))
		instance.died.connect(_on_Enemy_died.bind(key))
		instance.set_EXP(stats.get_EXP())
		instance.set_loot(stats.get_loot())
		instance.comph().call_comp("Stats", &"set_max_stat", [&"HP", stats.get_stat(&"HP")])
		instance.comph().call_comp("Stats", &"set_max_stat", [&"SP", stats.get_stat(&"SP")])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"HP", stats.get_stat(&"HP")])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"SP", stats.get_stat(&"SP")])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"ATK", stats.get_stat(&"ATK")])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"MAG", stats.get_stat(&"MAG")])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"DEF", stats.get_stat(&"DEF")])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"SPEED", stats.get_stat(&"SPEED")])
		instance.comph().call_comp("Stats", &"set_curr_stat", [&"LUCK", stats.get_stat(&"LUCK")])
		
		instance.set_encounter(self)
		instance.comph().call_comp("Actions", &"update_data", [actions])
		
		_a_characters[key] = instance
		_a_enemies[key] = instance
		_a_characters_alive[key] = instance
		_a_enemies_alive[key] = instance

func _handle_map_res() -> void:
	match _a_map_res:
		BattleSV.MAP_RES.PARTY_MEMBER:
			_a_instance = _a_Party_Members_Instances.get_child(0)
		BattleSV.MAP_RES.ENEMY:
			_a_instance = _a_Enemies_Instances.get_child(0)
		BattleSV.MAP_RES.NEUTRAL:
			_update_turn()
	_proceed_battle()

func _proceed_battle() -> void:
	var type: StringName = _a_instance.get_type()
	match type:
		&"Party_Member":
			_a_Command_Circle.open(_a_instance)
			var pos: Vector3 = _a_Command_Circle.get_global_position()
			_a_Indicators.open_command_circle(pos)
		&"Enemy":
			_a_instance.process_action_start()

func _update_turn() -> void:
	if _a_order_idx == _a_order.size() - 1:
		_update_order()
	_a_order_idx = (_a_order_idx + 1) % _a_order.size()
	
	var key: StringName = _a_order[_a_order_idx]
	_a_instance = _a_characters[key]

func _update_order() -> void:
	_a_order.clear()
	var order_args: Array = []
	for key: StringName in _a_characters_alive:
		var instance: SVCharacter = _a_characters_alive[key]
		var SPEED: int = instance.comph().call_comp("Stats", &"get_curr_stat", [&"SPEED"])
		instance.set_turn_completed(false)
		order_args.push_back([SPEED, key])
	order_args.sort_custom(Global.sort_high_nested)
	
	for args: Array in order_args:
		var key: StringName = args[1]
		_a_order.push_back(key)

func _erase_from_order(p_key: StringName) -> void:
	_a_order.erase(p_key)
	var instance: SVCharacter = _a_characters[p_key]
	var turn_completed: bool = instance.get_turn_completed()
	if turn_completed:
		_a_order_idx -= 1

func _game_over() -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	scene_manager_si.change_scene_dest([&"Game_Over", &"Start"])

func _knockback(p_instance: SVCharacter, p_dmg: int, p_dir_vec: Vector3) -> void:
	var velocity: Vector3 = p_dir_vec * p_dmg * 1.5
	p_instance.comph().call_comp("Movement/Knockbacks", &"knockback", [velocity])

func _loot_to_total_loot(p_loot: Dictionary, p_total_loot: Dictionary[StringName, int]) -> void:
	var rolled_loot: Dictionary[StringName, int] = Global.roll_loot(p_loot)
	for item_key: StringName in rolled_loot:
		var amount: int = rolled_loot[item_key]
		if p_total_loot.has(item_key):
			p_total_loot[item_key] += amount
		else:
			p_total_loot[item_key] = amount

func set_map_res(p_map_res: BattleSV.MAP_RES) -> void:
	_a_map_res = p_map_res

func set_troop(p_troop: Array[StringName]) -> void:
	_a_troop = p_troop

func set_bonus_loot(p_bonus_loot: Dictionary) -> void:
	_a_bonus_loot = p_bonus_loot

func set_special(p_special: bool) -> void:
	_a_special = p_special

func get_character(p_key: StringName) -> SVCharacter:
	return _a_characters[p_key]

func get_party_members() -> Dictionary[StringName, SVPartyMember]:
	return _a_party_members

func get_enemies() -> Dictionary[StringName, SVEnemy]:
	return _a_enemies

func get_free_camera() -> FWNode3DObject:
	return _a_Free_Camera

func get_free_audio() -> FWPausableAudio3D:
	return _a_Free_Audio

func get_flee_pos() -> Vector3:
	return _a_Flee_Pos.get_global_position()

func _get_pm_dmg_fac(p_rating: StringName) -> float:
	match p_rating:
		&"Nothing": return 0.5
		&"OK": return 0.75
		&"Good": return 1.0
		&"Great": return 1.25
		&"Excellent": return 1.5
		_: return 0.0

func _on_Command_Circle_changed(p_command: StringName) -> void:
	var text: String = _a_COMMAND_LOC_ID % p_command.to_upper()
	_a_Indicators.set_command_circle_command_text(text)

func _on_Command_Circle_selected(p_command: StringName) -> void:
	_a_instance.set_command(p_command)
	_a_Command_Circle.close()
	_a_Indicators.close_command_circle()
	
	var command_args: ActionData = _a_instance.get_curr_command_arg()
	var target_type: StringName = command_args.get_target_type()
	match target_type:
		&"None":
			match p_command:
				&"Special":
					_a_Specials_Menu.open(_a_instance)
					_a_Indicators.open_specials_menu()
				_:
					_a_instance.process_action_start()
		
		&"Ally":
			pass
		
		&"Enemy":
			_a_Enemy_Select.open(_a_enemies_alive)
			_a_Indicators.open_enemy_select()

func _on_Enemy_Select_changed(p_key: StringName, p_init: bool) -> void:
	var instance: SVEnemy = _a_enemies[p_key]
	_a_Indicators.update_enemy_select(instance, p_init)

func _on_Enemy_Select_canceled() -> void:
	_a_Indicators.close_enemy_select()
	
	var command: StringName = _a_instance.get_command()
	match command:
		&"Special":
			_a_Specials_Menu.open(_a_instance)
			_a_Indicators.open_specials_menu()
		_:
			_a_Command_Circle.open(_a_instance)
			var pos: Vector3 = _a_Command_Circle.get_global_position()
			_a_Indicators.open_command_circle(pos)

func _on_Enemy_Select_selected(p_key: StringName) -> void:
	_a_Indicators.close_enemy_select()
	
	var target: SVEnemy = _a_enemies[p_key]
	_a_instance.set_target(target)
	_a_instance.process_action_start()

func _on_Specials_Menu_selected(p_args: ActionData) -> void:
	var special: StringName = p_args.get_key()
	var target_type: StringName = p_args.get_target_type()
	_a_instance.set_special(special)
	_a_Indicators.close_specials_menu()
	
	match target_type:
		&"None":
			_a_instance.process_action_start()
		&"Ally":
			pass
		&"Enemy":
			_a_Enemy_Select.open(_a_enemies_alive)
			_a_Indicators.open_enemy_select()

func _on_Specials_Menu_canceled() -> void:
	_a_Indicators.close_specials_menu()
	
	_a_Command_Circle.open(_a_instance)
	var pos: Vector3 = _a_Command_Circle.get_global_position()
	_a_Indicators.open_command_circle(pos)

func _on_Character_action_started(p_instance: SVCharacter) -> void:
	p_instance.comph().call_comp("Status", &"handle_trigger_effects", [&"Action_Start"])

func _on_Character_action_finished() -> void:
	if _a_battle_ended:
		return
	
	_update_turn()
	_proceed_battle()

func _on_Character_action_canceled() -> void:
	_proceed_battle()

func _on_Character_action_pre_event(p_instance: SVCharacter) -> void:
	p_instance.comph().call_comp("Status", &"handle_trigger_effects", [&"Action_Pre_Event"])

func _on_Character_action_post_event(p_instance: SVCharacter) -> void:
	p_instance.comph().call_comp("Status", &"handle_trigger_effects", [&"Action_Post_Event"])

func _on_Party_Member_action_finished(p_instance: SVPartyMember) -> void:
	var command: StringName = p_instance.get_command()
	match command:
		&"Flee":
			battle_end(&"Flee")

func _on_Party_Member_hit(p_to: SVEnemy, p_from: SVPartyMember) -> void:
	deal_dmg_rating(p_from, p_to)

func _on_Party_Member_died(p_key: StringName) -> void:
	_a_characters_alive.erase(p_key)
	_a_party_members_alive.erase(p_key)
	_erase_from_order(p_key)
	
	if _a_party_members_alive.is_empty():
		_game_over()

func _on_Enemy_action_reaction_started(p_target: SVPartyMember) -> void:
	var reactions: Dictionary[StringName, StringName] = p_target.get_reactions()
	_a_Indicators.open_reaction(reactions)
	p_target.reaction_start()

func _on_Enemy_action_reaction_finished(p_target: SVPartyMember) -> void:
	_a_Indicators.close_reaction()
	p_target.reaction_end()

func _on_Enemy_hit(p_to: SVCharacter, p_from: SVCharacter) -> void:
	deal_dmg(p_from, p_to)

func _on_Enemy_died(p_key: StringName) -> void:
	_a_characters_alive.erase(p_key)
	_a_enemies_alive.erase(p_key)
	_erase_from_order(p_key)
	
	if _a_enemies_alive.is_empty():
		battle_end(&"Win")
