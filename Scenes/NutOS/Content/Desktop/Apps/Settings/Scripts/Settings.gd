extends "res://Scenes/NutOS/Content/Desktop/Apps/Scripts/App.gd"

signal app_installed(p_key)
signal app_uninstalled(p_key)

const _a_OPTIONS = ["Apps", "Keyboard", "Background"]
const _a_OPTION_ICON_PATH = "res://Scenes/NutOS/Content/Desktop/Apps/Settings/Sprites/%s.png"
const _a_OPTION_HEADING = "NUTOS_APP_SETTINGS_OPTIONS_%s_HEADING"
const _a_OPTION_DESC = "NUTOS_APP_SETTINGS_OPTIONS_%s_DESC"
const _a_MENU_PATH = "res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/%s/%s.tscn"

var _a_Option_Entry_Scene = preload("res://Scenes/NutOS/Content/Desktop/Apps/Settings/Option_Entry.tscn")

@onready var _a_Main = get_node("Contents/Main")
@onready var _a_Options = get_node("Contents/Main/VBox/Options/VBox")
@onready var _a_Menu = get_node("Contents/Menu")

var _a_desktop = null

var _a_menu_data = {} # Match menu key to save_data
var _a_menu_instance = null

func _ready():
	super()
	
	_instantiate_options()
	
	_a_Menu.hide()

func open(p_save_data):
	if p_save_data.is_empty():
		return
	
	_a_menu_data = p_save_data["Menu_Data"]
	for key in _a_menu_data:
		var args = _a_menu_data[key]
		if args.is_empty():
			continue
		
		if args["Open"]:
			_instantiate_menu(key)
	
	var pos = p_save_data["Pos"]
	set_position(pos)

func _instantiate_options():
	for key in _a_OPTIONS:
		var icon = load(_a_OPTION_ICON_PATH % key)
		var heading = _a_OPTION_HEADING % key.to_upper()
		var desc = _a_OPTION_DESC % key.to_upper()
		var instance = _a_Option_Entry_Scene.instantiate()
		instance.selected.connect(_on_Option_Entry_selected.bind(key))
		instance.set_icon.call_deferred(icon)
		instance.set_heading.call_deferred(heading)
		instance.set_desc.call_deferred(desc)
		
		_a_menu_data[key] = {}
		_a_Options.add_child(instance)

func _instantiate_menu(p_key):
	var scene = load(_a_MENU_PATH % [p_key, p_key])
	_a_menu_instance = scene.instantiate()
	_a_menu_instance.return_pressed.connect(_on_Menu_return_pressed)
	_a_menu_instance.option_selected.connect(_on_Menu_option_selected)
	_a_menu_instance.set_key(p_key)
	
	match p_key:
		"Apps":
			_a_menu_instance.app_installed.connect(_on_Apps_app_installed)
			_a_menu_instance.app_uninstalled.connect(_on_Apps_app_uninstalled)
			_a_menu_instance.set_desktop(_a_desktop)
	
	_a_menu_instance.open.call_deferred(_a_menu_data[p_key])
	
	_a_Menu.add_child(_a_menu_instance)
	
	var heading = _a_OPTION_HEADING % p_key.to_upper()
	set_title(heading)
	
	_a_Main.hide()
	_a_Menu.show()

func set_desktop(p_desktop):
	_a_desktop = p_desktop

func get_save_data(p_closed):
	var data = {}
	for child in _a_Menu.get_children():
		var key = child.get_key()
		_a_menu_data[key] = child.get_save_data()
		_a_menu_data[key]["Open"] = !p_closed
	data["Menu_Data"] = _a_menu_data
	data["Pos"] = get_position()
	
	return data

func _on_Option_Entry_selected(p_key):
	_instantiate_menu(p_key)

func _on_Menu_return_pressed():
	var key = _a_menu_instance.get_key()
	_a_menu_data[key] = _a_menu_instance.get_save_data()
	_a_menu_data[key]["Open"] = false
	
	_a_menu_instance.queue_free()
	_a_menu_instance = null
	
	set_title(tr("NUTOS_APP_SETTINGS"))
	
	_a_Main.show()
	_a_Menu.hide()

func _on_Menu_option_selected(p_key, p_option, p_value):
	option_selected.emit(p_key, p_option, p_value)

func _on_Apps_app_installed(p_key):
	app_installed.emit(p_key)

func _on_Apps_app_uninstalled(p_key):
	app_uninstalled.emit(p_key)

func _on_close_requested():
	_close()
