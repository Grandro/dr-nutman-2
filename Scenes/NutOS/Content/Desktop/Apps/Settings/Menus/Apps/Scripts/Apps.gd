extends NutOSContentDesktopAppSettingsMenuBase
class_name NutOSContentDesktopAppSettingsMenuApps

signal app_installed(p_key: StringName)
signal app_uninstalled(p_key: StringName)

var _a_App_Entry_Scene: PackedScene = preload("res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Apps/App_Entry.tscn")

@onready var _a_Sort_By: SortBy = get_node("VBox/VBox/Options/Sort_By")
@onready var _a_Search: Search = get_node("VBox/VBox/Options/Search")
@onready var _a_Entries: VBoxContainer = get_node("VBox/VBox/Scroll/Entries")

var _a_desktop: NutOSContentDesktop

var _a_entries: Dictionary[StringName, NutOSContentDesktopAppSettingsMenuAppsAppEntry] = {} # Match key to instance

func _ready() -> void:
	super()
	_a_Sort_By.option_selected.connect(_on_Sort_By_option_selected)
	_a_Search.input_text_changed.connect(_on_Search_input_text_changed)
	_a_desktop.app_registered.connect(_on_Desktop_app_registered)
	_a_desktop.app_unregistered.connect(_on_Desktop_app_unregistered)
	_a_desktop.app_opened.connect(_on_Desktop_app_opened)
	_a_desktop.app_closed.connect(_on_Desktop_app_closed)

func open(p_data: Dictionary) -> void:
	var entries_data: Dictionary = {}
	if !p_data.is_empty():
		entries_data = p_data[&"Entries"]
	
	_instantiate_entries(entries_data)
	_sort_entries.call_deferred()

func _instantiate_entries(p_data: Dictionary) -> void:
	var registered_apps: Array[StringName] = _a_desktop.get_registered_apps()
	for key: StringName in registered_apps:
		var args: Dictionary = {}
		if p_data.has(key):
			args = p_data[key]
		_instantiate_entry(key, args)

func _instantiate_entry(p_key: StringName, p_data: Dictionary) -> void:
	var instance: NutOSContentDesktopAppSettingsMenuAppsAppEntry = _a_App_Entry_Scene.instantiate()
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

func _delete_entry(p_key: StringName) -> void:
	var instance: NutOSContentDesktopAppSettingsMenuAppsAppEntry = _a_entries[p_key]
	instance.queue_free()
	_a_entries.erase(p_key)

func _sort_entries() -> void:
	var args: Array = _a_Sort_By.get_selected_args()
	var method_name: StringName = args[0]
	var rel: String = args[1]
	PropertySorter.sort(_a_Entries, method_name, rel)

func set_desktop(p_desktop: NutOSContentDesktop) -> void:
	_a_desktop = p_desktop

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Entries"] = {}
	for key: StringName in _a_entries:
		var instance: NutOSContentDesktopAppSettingsMenuAppsAppEntry = _a_entries[key]
		var entry_data: Dictionary = instance.get_save_data()
		data[&"Entries"][key] = entry_data
	
	return data

func _on_Sort_By_option_selected() -> void:
	_sort_entries()

func _on_Search_input_text_changed(p_text: String) -> void:
	var upper_text: String = p_text.to_upper()
	for child: NutOSContentDesktopAppSettingsMenuAppsAppEntry in _a_Entries.get_children():
		if upper_text.is_empty():
			child.show()
			continue
		
		var name_: String = child.get_name_()
		if upper_text in name_.to_upper():
			child.show()
		else:
			child.hide()

func _on_Desktop_app_registered(p_key: StringName) -> void:
	_instantiate_entry(p_key, {})
	_sort_entries()

func _on_Desktop_app_unregistered(p_key: StringName) -> void:
	_delete_entry(p_key)

func _on_Desktop_app_opened(p_key: StringName) -> void:
	var instance: NutOSContentDesktopAppSettingsMenuAppsAppEntry = _a_entries[p_key]
	instance.handle_app_opened()

func _on_Desktop_app_closed(p_key: StringName) -> void:
	var instance: NutOSContentDesktopAppSettingsMenuAppsAppEntry = _a_entries[p_key]
	instance.handle_app_closed()

func _on_App_Entry_installed(p_key: StringName) -> void:
	_sort_entries()
	app_installed.emit(p_key)

func _on_App_Entry_uninstalled(p_key: StringName) -> void:
	_sort_entries()
	app_uninstalled.emit(p_key)
