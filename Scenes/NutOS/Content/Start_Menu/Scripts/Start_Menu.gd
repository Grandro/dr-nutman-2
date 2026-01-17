extends PanelContainer
class_name NutOSContentStartMenu

signal closed()
signal request_app(p_key: StringName)
signal power_option_selected(p_option: StringName)

const _a_APP_PATH: String = "res://Scenes/NutOS/Content/Start_Menu/Apps/%s.tscn"

@onready var _a_Icons: NutOSContentStartMenuIcons = get_node("HBox/Icons")
@onready var _a_App_List: VBoxContainer = get_node("HBox/App_List/VBox")

var _a_apps: Dictionary[StringName, NutOSContentStartMenuApp] = {} # Match key to instance
var _a_highlighted_app: NutOSContentStartMenuApp = null

func _ready() -> void:
	_a_Icons.settings_pressed.connect(_on_Icons_settings_pressed)
	_a_Icons.power_option_selected.connect(_on_Icons_power_option_selected)
	
	hide()

func open() -> void:
	show()

func close() -> void:
	_a_Icons.expand_collapse(false)
	hide()
	
	closed.emit()

func instantiate_app(p_key: StringName) -> void:
	var scene_path: String = _a_APP_PATH % p_key
	var scene: PackedScene = load(scene_path)
	var instance: NutOSContentStartMenuApp = scene.instantiate()
	instance.select_pressed.connect(_on_App_select_pressed.bind(p_key))
	instance.set_key(p_key)
	
	_a_apps[p_key] = instance
	_a_App_List.add_child(instance)
	_a_App_List.move_child(instance, 0)

func delete_app(p_key: StringName) -> void:
	var instance: NutOSContentStartMenuApp = _a_apps[p_key]
	instance.queue_free()
	_a_apps.erase(p_key)

func filter_app_list(p_text: String) -> void:
	var upper_text: String = p_text.to_upper()
	var first: NutOSContentStartMenuApp = null
	for child: NutOSContentStartMenuApp in _a_App_List.get_children():
		if upper_text.is_empty():
			child.show()
			continue
		
		var name_: String = child.get_name_()
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

func open_highlighted_app() -> void:
	if _a_highlighted_app == null:
		return
	
	var key: StringName = _a_highlighted_app.get_key()
	request_app.emit(key)
	
	close()

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	
	var apps_list: Array[StringName] = []
	for i: int in range(_a_App_List.get_child_count() - 1, -1, -1):
		var child: NutOSContentStartMenuApp = _a_App_List.get_child(i)
		var key: StringName = child.get_key()
		apps_list.push_back(key)
	data[&"Apps_List"] = apps_list
	
	return data

func load_data(p_data: Dictionary) -> void:
	var apps_list: Array[StringName] = p_data[&"Apps_List"]
	for key: StringName in apps_list:
		instantiate_app(key)

func _on_Icons_settings_pressed() -> void:
	request_app.emit(&"Settings")
	close()

func _on_Icons_power_option_selected(p_option: StringName) -> void:
	power_option_selected.emit(p_option)
	close()

func _on_App_select_pressed(p_key: StringName) -> void:
	request_app.emit(p_key)
	close()
