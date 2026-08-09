extends Control
class_name FWTitleScreenProgressBase

signal request_progress_update()

const _a_LOCALE_LOC_ID: String = "LOCALE_%s"
const _a_LOCALE_ICON_PATH: String = "res://Global_Resources/Sprites/Icons/Locales/%s.png"

@onready var _a_Locale: OptionButton = get_node("Locale")
@onready var _a_Menu_Journal: MainMenuSubMenuJournal = get_node("Journal")
@onready var _a_Menu_Options: MainMenuSubMenuOptions = get_node("Options")
@onready var _a_Menu_Credits: FWTitleScreenCredits = get_node("Credits")

var _a_locale_idxs: Dictionary[String, int] = {} # Match locale to idx

func _ready() -> void:
	_a_Locale.item_selected.connect(_on_Locale_item_selected)
	_a_Menu_Journal.closed.connect(_on_Menu_Journal_closed)
	
	_create_locale_options()
	
	var locale: String = Global_Data.get_locale()
	var idx: int = _a_locale_idxs[locale]
	_a_Locale.select(idx)
	
	_a_Menu_Journal.hide()

func _create_locale_options() -> void:
	var loaded_locales: PackedStringArray = TranslationServer.get_loaded_locales()
	for i: int in loaded_locales.size():
		var locale: String = loaded_locales[i]
		var text: String = tr(_a_LOCALE_LOC_ID % locale.to_upper())
		var icon: Texture2D = load(_a_LOCALE_ICON_PATH % locale)
		
		_a_locale_idxs[locale] = i
		_a_Locale.add_icon_item(icon, text)
		_a_Locale.set_item_metadata(i, locale)

func _on_Locale_item_selected(p_idx: int) -> void:
	var locale: String = _a_Locale.get_item_metadata(p_idx)
	Global_Data.set_locale(locale)
	Global_Data.save_data()

func _on_Menu_Journal_closed(_p_data: Dictionary) -> void:
	request_progress_update.emit()

func _on_Start_pressed() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	global_si.start_game()
	
	#var dest: Array[StringName] = [&"Doctor_Dream_1", &"Start"]
	#var dest: Array[StringName] = [&"Dr_Nutman_Home_1", &"Start"]
	#var dest: Array[StringName] = [&"Broko_Town_1", &"Dr_Nutman_House"]
	#var dest: Array[StringName] = [&"Broko_House_1", &"Door"]
	#var dest: Array[StringName] = [&"Broko_House_2", &"Door"]
	#var dest: Array[StringName] = [&"Broko_House_3", &"Door"]
	#var dest: Array[StringName] = [&"Buffin_House_1", &"Door"]
	#var dest: Array[StringName] = [&"Buffin_House_2", &"Door"]
	var dest: Array[StringName] = [&"Buffin_House_3", &"Door"]
	#var dest: Array[StringName] = [&"Buffin_House_3", &"Stairway_2"]
	#var dest: Array[StringName] = [&"Buffin_House_3", &"Stairway_4"]
	#var dest: Array[StringName] = [&"Buffin_House_3", &"Stairway_5"]
	#var dest: Array[StringName] = [&"Buffin_House_3", &"Stairway_6"]
	#var dest: Array[StringName] = [&"Broko_Forest_1", &"Test"]
	#var dest: Array[StringName] = [&"Debug_3D", &"Start"]
	#var dest: Array[StringName] = [&"Debug_2D", &"Start"]
	#var dest: Array[StringName] = [&"Game_Over", &"Start"]
	
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	scene_manager_si.change_scene_dest(dest)
	
	#var enc_key: StringName = &"SP_Sick_Apprentice_1"
	#var enc_key: StringName = &"Broko_Forest_1"
	#var enc_key: StringName = &"Ghost_House_1"
	#var troop: Array[StringName] = []
	#var troop: Array[StringName] = [&"Citrin"]
	#var troop: Array[StringName] = [&"Citrin", &"Citrin"]
	#var troop: Array[StringName] = [&"Ghosty"]
	#var troop: Array[StringName] = [&"Ghosty", &"Ghosty"]
	#
	#var battle_system_si: Battle_System = Global.get_singleton(self, &"Battle_System")
	#var battle_sv: BattleSV = battle_system_si.get_battle_sv()
	#battle_sv.battle(enc_key, BattleSV.MAP_RES.NEUTRAL, troop)

func _on_Load_pressed() -> void:
	_a_Menu_Journal.open()

func _on_Options_pressed() -> void:
	_a_Menu_Options.open()

func _on_Credits_pressed() -> void:
	_a_Menu_Credits.open()

func _on_Quit_pressed() -> void:
	get_tree().quit()
