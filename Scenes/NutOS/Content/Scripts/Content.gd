extends Control

@onready var _a_Canvas = get_node("Canvas")
@onready var _a_Desktop = get_node("Desktop")
@onready var _a_Start_Menu = get_node("Canvas/Start_Menu")
@onready var _a_Taskbar = get_node("Canvas/Taskbar")

func _ready():
	_a_Desktop.app_installed.connect(_on_Desktop_app_installed)
	_a_Desktop.app_uninstalled.connect(_on_Desktop_app_uninstalled)
	_a_Desktop.app_opened.connect(_on_Desktop_app_opened)
	_a_Desktop.app_closed.connect(_on_Desktop_app_closed)
	_a_Desktop.app_focus_entered.connect(_on_Desktop_app_focus_entered)
	_a_Start_Menu.closed.connect(_on_Start_Menu_closed)
	_a_Start_Menu.request_app.connect(_on_Start_Menu_request_app)
	_a_Taskbar.start_select_pressed.connect(_on_Taskbar_start_select_pressed)
	_a_Taskbar.search_text_changed.connect(_on_Taskbar_search_text_changed)
	_a_Taskbar.search_text_submitted.connect(_on_Taskbar_search_text_submitted)
	_a_Taskbar.search_focus_entered.connect(_on_Taskbar_search_focus_entered)
	_a_Taskbar.app_select_pressed.connect(_on_Taskbar_app_select_pressed)
	
	_a_Canvas.set_layer(1024)

func get_save_data():
	var data = {}
	data["Desktop"] = _a_Desktop.get_save_data()
	data["Start_Menu"] = _a_Start_Menu.get_save_data()
	
	return data

func load_data(p_data):
	_a_Desktop.load_data(p_data["Desktop"])
	_a_Start_Menu.load_data(p_data["Start_Menu"])

func load_data_init():
	_a_Desktop.load_data_init()

func _on_Desktop_app_installed(p_key):
	_a_Start_Menu.instantiate_app(p_key)

func _on_Desktop_app_uninstalled(p_key):
	_a_Start_Menu.delete_app(p_key)

func _on_Desktop_app_opened(p_key):
	_a_Taskbar.instantiate_app(p_key)

func _on_Desktop_app_closed(p_key):
	_a_Taskbar.delete_app(p_key)

func _on_Desktop_app_focus_entered(p_key):
	_a_Taskbar.highlight_app(p_key)

func _on_Start_Menu_closed():
	_a_Taskbar.set_search_text("")

func _on_Start_Menu_request_app(p_key):
	_a_Desktop.open_app(p_key)

func _on_Taskbar_start_select_pressed():
	if _a_Start_Menu.is_visible():
		_a_Start_Menu.close()
	else:
		_a_Start_Menu.open()

func _on_Taskbar_search_text_changed(p_text):
	_a_Start_Menu.filter_app_list(p_text)

func _on_Taskbar_search_text_submitted(_p_text):
	_a_Start_Menu.open_highlighted_app()

func _on_Taskbar_search_focus_entered():
	_a_Start_Menu.open()

func _on_Taskbar_app_select_pressed(p_key):
	_a_Desktop.focus_app(p_key)
