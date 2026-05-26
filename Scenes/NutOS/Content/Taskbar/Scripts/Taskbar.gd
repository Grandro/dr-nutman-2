extends MarginContainer
class_name NutOSContentTaskbar

signal start_select_pressed()
signal start_option_selected(p_option: StringName)
signal search_text_changed(p_text: String)
signal search_text_submitted(p_text: String)
signal search_focus_entered()
signal app_select_pressed(p_key: StringName)

const _a_APP_PATH: String = "res://Scenes/NutOS/Content/Taskbar/Apps/%s.tscn"

@onready var _a_Start_Select: TextureButton = get_node("Tools/Left/Start/Select")
@onready var _a_Start_Options: FWContextMenu = get_node("Tools/Left/Start/Options")
@onready var _a_Search: FWSearch = get_node("Tools/Left/Search")
@onready var _a_Apps: HBoxContainer = get_node("Tools/Right/Apps")

var _a_apps: Dictionary[StringName, NutOSContentTaskbarApp] = {} # Match app key to instance
var _a_highlighted_app: NutOSContentTaskbarApp = null # Highlighted app instance

func _ready() -> void:
	_a_Start_Select.pressed.connect(_on_Start_Select_pressed)
	_a_Start_Select.gui_input.connect(_on_Start_Select_gui_input)
	_a_Start_Options.option_selected.connect(_on_Start_Options_option_selected)
	_a_Search.input_text_changed.connect(_on_Search_input_text_changed)
	_a_Search.input_text_submitted.connect(_on_Search_input_text_submitted)
	_a_Search.input_focus_entered.connect(_on_Search_input_focus_entered)
	
	_a_Start_Options.set_layer(1026)

func instantiate_app(p_key: StringName) -> void:
	var scene: PackedScene = load(_a_APP_PATH % p_key)
	var instance: NutOSContentTaskbarApp = scene.instantiate()
	instance.select_pressed.connect(_on_App_select_pressed.bind(p_key))
	
	_a_apps[p_key] = instance
	_a_Apps.add_child(instance)

func delete_app(p_key: StringName) -> void:
	var instance: NutOSContentTaskbarApp = _a_apps[p_key]
	instance.queue_free()
	_a_apps.erase(p_key)

func highlight_app(p_key: StringName) -> void:
	if is_instance_valid(_a_highlighted_app):
		_a_highlighted_app.highlight(false)
	
	var instance: NutOSContentTaskbarApp = _a_apps[p_key]
	instance.highlight(true)
	_a_highlighted_app = instance

func set_search_text(p_text: String) -> void:
	_a_Search.set_input_text(p_text)
	search_text_changed.emit(p_text)

func _on_Start_Select_pressed() -> void:
	start_select_pressed.emit()

func _on_Start_Select_gui_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Mouse_Right"):
		var pos: Vector2 = p_event.get_global_position()
		_a_Start_Options.open(pos)

func _on_Start_Options_option_selected(p_option: StringName) -> void:
	start_option_selected.emit(p_option)

func _on_Search_input_text_changed(p_text: String) -> void:
	search_text_changed.emit(p_text)

func _on_Search_input_text_submitted(p_text: String) -> void:
	search_text_submitted.emit(p_text)

func _on_Search_input_focus_entered() -> void:
	search_focus_entered.emit()

func _on_App_select_pressed(p_key: StringName) -> void:
	app_select_pressed.emit(p_key)
