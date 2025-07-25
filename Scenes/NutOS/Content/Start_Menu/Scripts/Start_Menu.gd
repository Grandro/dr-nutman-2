extends PanelContainer

signal closed()
signal request_app(p_key)
signal power_option_selected(p_option)

const _a_APP_PATH = "res://Scenes/NutOS/Content/Start_Menu/Apps/%s.tscn"

@onready var _a_Icons = get_node("HBox/Icons")
@onready var _a_App_List = get_node("HBox/App_List/VBox")

var _a_apps = {} # Match key to instance
var _a_highlighted_app = null

func _ready():
	_a_Icons.settings_pressed.connect(_on_Icons_settings_pressed)
	_a_Icons.power_option_selected.connect(_on_Icons_power_option_selected)
	
	hide()

func open():
	show()

func close():
	_a_Icons.expand_collapse(false)
	hide()
	
	closed.emit()

func instantiate_app(p_key):
	var scene_path = _a_APP_PATH % p_key
	var scene = load(scene_path)
	var instance = scene.instantiate()
	instance.select_pressed.connect(_on_App_select_pressed.bind(p_key))
	instance.set_key(p_key)
	
	_a_apps[p_key] = instance
	_a_App_List.add_child(instance)
	_a_App_List.move_child(instance, 0)

func delete_app(p_key):
	var instance = _a_apps[p_key]
	instance.queue_free()
	_a_apps.erase(p_key)

func filter_app_list(p_text):
	var upper_text = p_text.to_upper()
	var first = null
	for child in _a_App_List.get_children():
		if upper_text.is_empty():
			child.show()
			continue
		
		var name_ = child.get_name_()
		if upper_text in name_.to_upper():
			if first == null:
				first = child
			child.show()
		else:
			child.hide()
	
	if _a_highlighted_app != null:
		_a_highlighted_app.set_highlighted(false)
	if first != null:
		first.set_highlighted(true)
	_a_highlighted_app = first

func open_highlighted_app():
	if _a_highlighted_app == null:
		return
	
	var key = _a_highlighted_app.get_key()
	request_app.emit(key)
	
	close()

func get_save_data():
	var data = {}
	
	var apps_list = []
	for i in range(_a_App_List.get_child_count() - 1, -1, -1):
		var child = _a_App_List.get_child(i)
		var key = child.get_key()
		apps_list.push_back(key)
	data["Apps_List"] = apps_list
	
	return data

func load_data(p_data):
	var apps_list = p_data["Apps_List"]
	for key in apps_list:
		instantiate_app(key)

func _on_Icons_settings_pressed():
	request_app.emit("Settings")
	close()

func _on_Icons_power_option_selected(p_option):
	power_option_selected.emit(p_option)
	close()

func _on_App_select_pressed(p_key):
	request_app.emit(p_key)
	close()
