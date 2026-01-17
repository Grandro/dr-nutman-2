extends Control
class_name MainMenuMenuBase

signal request_menu(p_scene: PackedScene)
signal request_sub_menu(p_key: StringName, p_scene: PackedScene)

@export var _e_sub_menus: Array[StringName] = []

var _a_data: Dictionary = {}
var _a_selected: MainMenuMenuIcon # Selected Menu_Icon

func open() -> void:
	_a_selected.grab_image_focus()
	show()

func close() -> void:
	hide()
	queue_free()

func _init_menu_icons(p_parent: Container) -> void:
	var select: bool = true
	for child: MainMenuMenuIcon in p_parent.get_children():
		var key: StringName = child.get_key()
		var unlocked: bool = _a_data[key][&"Unlocked"]
		child.pressed.connect(_on_Menu_Icon_pressed.bind(child))
		child.set_visible(unlocked)
		
		if select && unlocked:
			_a_selected = child
			select = false

func get_sub_menus() -> Array[StringName]:
	return _e_sub_menus

func set_data(p_data: Dictionary) -> void:
	_a_data = p_data

func _on_Menu_Icon_pressed(p_instance: MainMenuMenuIcon) -> void:
	_a_selected = p_instance
	
	var scene: PackedScene = p_instance.get_menu_scene()
	var type: StringName = p_instance.get_type()
	match type:
		&"Menu":
			request_menu.emit(scene)
		&"Sub_Menu":
			var key: StringName = p_instance.get_key()
			request_sub_menu.emit(key, scene)
