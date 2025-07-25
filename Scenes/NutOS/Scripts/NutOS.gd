extends "res://Scenes/VP_Container/Scripts/VP_Container.gd"

signal shutdown()
signal app_option_selected(p_key, p_option, p_value)

@onready var _a_Content = get_node("VP/Content")
@onready var _a_Background = get_node("VP/Content/Background")
@onready var _a_Desktop = get_node("VP/Content/Desktop")
@onready var _a_Taskbar = get_node("VP/Content/Canvas/Taskbar")
@onready var _a_Start_Menu = get_node("VP/Content/Canvas/Start_Menu")

var _a_active = false
var _a_disk_app_key = "" # App key of inserted disk

func _ready():
	_a_Desktop.app_uninstalled.connect(_on_Desktop_app_uninstalled)
	_a_Desktop.app_option_selected.connect(_on_Desktop_app_option_selected)
	_a_Taskbar.start_option_selected.connect(_on_power_option_selected)
	_a_Start_Menu.power_option_selected.connect(_on_power_option_selected)
	
	_a_VP.set_disable_input(true)
	_a_VP.set_handle_input_locally(true)
	
	hide()

func boot():
	var global_si = Global.get_singleton(self, "Global")
	var player = global_si.get_player()
	player.comph().call_comp("Operate", "disable")
	
	_a_active = true
	_a_VP.set_disable_input(false)
	_a_VP.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	show()

func close():
	var global_si = Global.get_singleton(self, "Global")
	var player = global_si.get_player()
	player.comph().call_comp("Operate", "enable")
	
	_a_VP.set_disable_input(true)
	_a_VP.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	hide()

func get_vp_texture():
	return _a_VP.get_texture()

func get_save_data():
	var texture = _a_Background.get_texture()
	var data = {}
	data["Active"] = _a_active
	data["Background"] = texture.get_path()
	data["Content"] = _a_Content.get_save_data()
	
	return data

func load_data(p_data):
	_a_active = p_data["Active"]
	if _a_active:
		_a_VP.set_update_mode(SubViewport.UPDATE_ALWAYS)
	
	var texture = load(p_data["Background"])
	_a_Background.set_texture(texture)
	_a_Content.load_data(p_data["Content"])

func load_data_init():
	_a_Content.load_data_init()

func _on_Desktop_app_uninstalled(p_key):
	if p_key != _a_disk_app_key:
		_a_Desktop.deregister_app(p_key)

func _on_Desktop_app_option_selected(p_key, p_option, p_value):
	match p_key:
		"Settings_Background":
			match p_option:
				"Static_Background":
					_a_Background.set_texture(p_value)
	
	app_option_selected.emit(p_key, p_option, p_value)

func _on_power_option_selected(p_option):
	match p_option:
		"Shutdown":
			close()
			_a_active = false
			shutdown.emit()
		
		"Leave":
			close()
			_a_VP.set_update_mode(SubViewport.UPDATE_ALWAYS)

func _on_Disk_Drive_slot_inserted(p_item_key):
	_a_disk_app_key = p_item_key.trim_prefix("Disk_")
	if !_a_Desktop.is_app_registered(_a_disk_app_key):
		_a_Desktop.register_app(_a_disk_app_key)

func _on_Disk_Drive_slot_removed():
	if !_a_Desktop.is_app_installed(_a_disk_app_key):
		_a_Desktop.deregister_app(_a_disk_app_key)
	
	_a_disk_app_key = ""
