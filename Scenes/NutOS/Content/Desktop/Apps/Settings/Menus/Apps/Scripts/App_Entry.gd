extends MarginContainer

signal installed()
signal uninstalled()

const _a_INSTALLED_APP_TEXTURE_PATH = "res://Scenes/NutOS/Content/Desktop/Apps/Sprites/Installed/%s.png"
const _a_NAME_LOC_ID = "NUTOS_APP_%s"
const _a_INSTALL_LOC_ID = "INSTALL"
const _a_UNINSTALL_LOC_ID = "UNINSTALL"

var _a_Install_Icon = preload("res://Global_Resources/Sprites/UI/Arrow_Down_Normal.png")
var _a_Uninstall_Icon = preload("res://Global_Resources/Sprites/UI/Delete_Normal.png")

@onready var _a_Icon = get_node("HBox/Icon")
@onready var _a_Name = get_node("HBox/VBox/Name")
@onready var _a_Date = get_node("HBox/VBox/Date")
@onready var _a_Install = get_node("HBox/Install")

var _a_key = ""
var _a_installed = false
var _a_unix_time = -1.0

func _ready():
	_a_Install.pressed.connect(_on_Install_pressed)
	
	_a_Name.set_text(tr(_a_NAME_LOC_ID % _a_key.to_upper()))

func open(p_data):
	_a_unix_time = p_data["Unix_Time"]
	_set_installed(p_data["Installed"])

func open_init():
	match _a_key:
		"Settings":
			# Settings has to be preinstalled
			_a_unix_time = Time.get_unix_time_from_system()
			_set_installed(true)
		_:
			_set_installed(false)

func handle_app_opened():
	_a_Install.set_disabled(true)

func handle_app_closed():
	_a_Install.set_disabled(false)

func _update_icon(p_installed):
	var item_texture = null
	if p_installed:
		item_texture = load(_a_INSTALLED_APP_TEXTURE_PATH % _a_key)
	else:
		var item_name = "Disk_%s" % _a_key
		var item_args = Databases.get_data_entry("Items", item_name)
		item_texture = item_args.get_texture()
	
	_a_Icon.set_texture(item_texture)

func _update_date(p_installed):
	if p_installed:
		var datetime = Time.get_datetime_dict_from_unix_time(_a_unix_time)
		var year = datetime["year"]
		var month = datetime["month"]
		var day = datetime["day"]
		var date_text = Global.get_date_text(year, month, day)
		_a_Date.set_text(date_text)
	else:
		_a_Date.set_text("-")

func _update_install(p_installed):
	if p_installed:
		_a_Install.set_text(tr(_a_UNINSTALL_LOC_ID))
		_a_Install.set_button_icon(_a_Uninstall_Icon)
	else:
		_a_Install.set_text(tr(_a_INSTALL_LOC_ID))
		_a_Install.set_button_icon(_a_Install_Icon)

func get_name_():
	return _a_Name.get_text()

func get_unix_time():
	return _a_unix_time

func set_key(p_key):
	_a_key = p_key

func _set_installed(p_installed):
	_a_installed = p_installed
	
	_update_icon(p_installed)
	_update_date(p_installed)
	_update_install(p_installed)

func get_save_data():
	var data = {}
	data["Installed"] = _a_installed
	data["Unix_Time"] = _a_unix_time
	
	return data

func _on_Install_pressed():
	if _a_installed:
		_a_unix_time = -1.0
		_set_installed(false)
		uninstalled.emit()
	else:
		_a_unix_time = Time.get_unix_time_from_system()
		_set_installed(true)
		installed.emit()
