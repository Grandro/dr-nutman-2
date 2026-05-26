extends CanvasLayer
class_name FWMainMenu

var _a_Main_Scene: PackedScene = preload("uid://ur4d3omh4swl")

@onready var _a_Menus: Control = get_node("Menus")

var _a_save_data: Dictionary = {}

var _a_active: bool = false # Is currently active?
var _a_stack: Array[Control] = [] # all menu instances

func _ready() -> void:
	hide()

func open() -> void:
	Global.pause()
	_a_active = true
	open_menu(_a_Main_Scene)
	
	show()

func open_menu(p_scene: PackedScene) -> void:
	_disable_last()
	
	var instance: FWMainMenuMenuBase = _instantiate_menu(p_scene)
	var data: Dictionary = {}
	for key: StringName in instance.get_sub_menus():
		data[key] = _a_save_data[&"Sub_Menus"][key][&"General"]
	instance.set_data(data)
	instance.open.call_deferred()
	
	_a_stack.push_back(instance)
	_a_Menus.add_child(instance)

func open_sub_menu(p_key: StringName, p_scene: PackedScene) -> void:
	_disable_last()
	
	var data: Dictionary = _a_save_data[&"Sub_Menus"][p_key][&"Menu"]
	var instance: Control = _instantiate_sub_menu(p_key, p_scene)
	instance.open.call_deferred(data)
	
	_a_stack.push_back(instance)
	_a_Menus.add_child(instance)

func _enable_last() -> void:
	var last: Control = _a_stack[-1]
	last.set_process_input(true)
	last.open()

func _disable_last() -> void:
	if !_a_stack.is_empty():
		var last: Control = _a_stack[-1]
		last.set_process_input(false)
		last.hide()

func close() -> void:
	_a_stack.clear()
	for child: Control in _a_Menus.get_children():
		child.tree_exiting.disconnect(_on_Menu_tree_exiting)
		child.queue_free()
	_a_active = false
	await get_tree().process_frame
	hide()
	
	Global.unpause()

func unlock_sub_menu(p_key: StringName) -> void:
	var sub_menu_data: Dictionary = _a_save_data[&"Sub_Menus"]
	sub_menu_data[p_key][&"General"][&"Unlocked"] = true

func _instantiate_menu(p_scene: PackedScene) -> FWMainMenuMenuBase:
	var instance: FWMainMenuMenuBase = p_scene.instantiate()
	instance.tree_exiting.connect(_on_Menu_tree_exiting)
	instance.request_menu.connect(_on_Menu_request_menu)
	instance.request_sub_menu.connect(_on_Menu_request_sub_menu)
	
	return instance

func _instantiate_sub_menu(p_key: StringName, p_scene: PackedScene) -> Control:
	var instance: Control = p_scene.instantiate()
	instance.tree_exiting.connect(_on_Menu_tree_exiting)
	instance.closed.connect(_on_Sub_Menu_closed.bind(p_key))
	
	return instance

func is_openable() -> bool:
	return !_a_active

func is_sub_menu_unlocked(p_key: StringName) -> bool:
	var sub_menu_data: Dictionary = _a_save_data[&"Sub_Menus"]
	var unlocked: bool = sub_menu_data[p_key][&"General"][&"Unlocked"]
	
	return unlocked

func reset() -> void:
	var main_menu_data: Dictionary = Databases.get_data(&"Main_Menu")
	_a_save_data.clear()
	_a_save_data[&"Sub_Menus"] = {}
	
	var sub_menu_data: Dictionary = _a_save_data[&"Sub_Menus"]
	for key: StringName in main_menu_data[&"Sub_Menus"]:
		var res: FWSubMenuData = main_menu_data[&"Sub_Menus"][key]
		sub_menu_data[key] = {}
		sub_menu_data[key][&"General"] = {}
		sub_menu_data[key][&"General"][&"Unlocked"] = res.is_unlocked()
		sub_menu_data[key][&"Menu"] = {}

func get_save_data() -> Dictionary:
	return _a_save_data

func load_file_data(p_data: Dictionary) -> void:
	_a_save_data = p_data

func _on_Menu_request_menu(p_scene: PackedScene) -> void:
	open_menu(p_scene)

func _on_Menu_request_sub_menu(p_key: StringName, p_scene: PackedScene) -> void:
	open_sub_menu(p_key, p_scene)

func _on_Sub_Menu_closed(p_data: Dictionary, p_key: StringName) -> void:
	_a_save_data[&"Sub_Menus"][p_key][&"Menu"] = p_data

func _on_Menu_tree_exiting() -> void:
	_a_stack.pop_back()
	if _a_stack.is_empty():
		close()
	else:
		_enable_last()
