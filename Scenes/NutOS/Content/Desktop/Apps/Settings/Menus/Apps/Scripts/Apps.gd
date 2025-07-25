extends "res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Scripts/Menu_Base.gd"

signal app_installed(p_key)
signal app_uninstalled(p_key)

var _a_App_Entry_Scene = preload("res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Apps/App_Entry.tscn")

@onready var _a_Sort_By = get_node("VBox/VBox/Options/Sort_By")
@onready var _a_Search = get_node("VBox/VBox/Options/Search")
@onready var _a_Entries = get_node("VBox/VBox/Scroll/Entries")

var _a_desktop = null

var _a_entries = {} # Match key to instance

func _ready():
	super()
	_a_Sort_By.option_selected.connect(_on_Sort_By_option_selected)
	_a_Search.input_text_changed.connect(_on_Search_input_text_changed)
	_a_desktop.app_registered.connect(_on_Desktop_app_registered)
	_a_desktop.app_unregistered.connect(_on_Desktop_app_unregistered)
	_a_desktop.app_opened.connect(_on_Desktop_app_opened)
	_a_desktop.app_closed.connect(_on_Desktop_app_closed)

func open(p_data):
	var entries_data = {}
	if !p_data.is_empty():
		entries_data = p_data["Entries"]
	
	_instantiate_entries(entries_data)
	_sort_entries.call_deferred()

func _instantiate_entries(p_data):
	var registered_apps = _a_desktop.get_registered_apps()
	for key in registered_apps:
		var args = {}
		if p_data.has(key):
			args = p_data[key]
		
		_instantiate_entry(key, args)

func _instantiate_entry(p_key, p_data):
	var instance = _a_App_Entry_Scene.instantiate()
	instance.installed.connect(_on_App_Entry_installed.bind(p_key))
	instance.uninstalled.connect(_on_App_Entry_uninstalled.bind(p_key))
	instance.set_key(p_key)
	
	if p_data.is_empty():
		instance.open_init.call_deferred()
	else:
		instance.open.call_deferred(p_data)
	
	if _a_desktop.is_app_open(p_key):
		instance.handle_app_opened.call_deferred()
	else:
		instance.handle_app_closed.call_deferred()
	
	_a_entries[p_key] = instance
	_a_Entries.add_child(instance)

func _delete_entry(p_key):
	var instance = _a_entries[p_key]
	instance.queue_free()
	_a_entries.erase(p_key)

func _sort_entries():
	var args = _a_Sort_By.get_selected_args()
	var method_name = args[0]
	var rel = args[1]
	PropertySorter.sort(_a_Entries, method_name, rel)

func set_desktop(p_desktop):
	_a_desktop = p_desktop

func get_save_data():
	var data = {}
	
	data["Entries"] = {}
	for key in _a_entries:
		var instance = _a_entries[key]
		var entry_data = instance.get_save_data()
		data["Entries"][key] = entry_data
	
	return data

func _on_Sort_By_option_selected():
	_sort_entries()

func _on_Search_input_text_changed(p_text):
	var upper_text = p_text.to_upper()
	for child in _a_Entries.get_children():
		if upper_text.is_empty():
			child.show()
			continue
		
		var name_ = child.get_name_()
		if upper_text in name_.to_upper():
			child.show()
		else:
			child.hide()

func _on_Desktop_app_registered(p_key):
	_instantiate_entry(p_key, {})
	_sort_entries()

func _on_Desktop_app_unregistered(p_key):
	_delete_entry(p_key)

func _on_Desktop_app_opened(p_key):
	var instance = _a_entries[p_key]
	instance.handle_app_opened()

func _on_Desktop_app_closed(p_key):
	var instance = _a_entries[p_key]
	instance.handle_app_closed()

func _on_App_Entry_installed(p_key):
	_sort_entries()
	app_installed.emit(p_key)

func _on_App_Entry_uninstalled(p_key):
	_sort_entries()
	app_uninstalled.emit(p_key)
