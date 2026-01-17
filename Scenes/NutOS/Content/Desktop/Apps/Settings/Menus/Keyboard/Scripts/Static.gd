extends VBoxContainer
class_name NutOSContentDesktopAppSettingsMenuKeyboardStatic

signal color_selected(p_color: Color, p_is_fav_color: bool)

var _a_Color_Entry_Scene: PackedScene = preload("res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Keyboard/Color_Entry.tscn")

@onready var _a_Available: HFlowContainer = get_node("Available/HFlow")

var _a_selected: NutOSContentDesktopAppSettingsMenuKeyboardColorEntry
var _a_fav_color_selected: bool = false

func _ready() -> void:
	Global_Data.fav_color_changed.connect(_on_Global_Data_fav_color_changed)
	
	hide()

func _update_available_colors(p_selected: Color) -> void:
	for child: NutOSContentDesktopAppSettingsMenuKeyboardColorEntry in _a_Available.get_children():
		child.queue_free()
	
	var data: Dictionary = Global_Data.get_entry_data(&"Fav_Color")
	var prev: PackedColorArray = data[&"Prev"]
	var fav_color: Color = data[&"Selected"]
	var fav_instance: NutOSContentDesktopAppSettingsMenuKeyboardColorEntry = _instantiate_available_color(fav_color, _a_fav_color_selected, true)
	
	var was_selected: bool = _a_fav_color_selected
	for color: Color in prev:
		var selected: bool = false
		if !_a_fav_color_selected && color == p_selected:
			selected = true
			was_selected = true
		_instantiate_available_color(color, selected, false)
	
	if !was_selected:
		fav_instance.select.call_deferred()
		_a_selected = fav_instance
		color_selected.emit(fav_color, true)

func _instantiate_available_color(p_color: Color, p_selected: bool, p_is_fav_color: bool) -> NutOSContentDesktopAppSettingsMenuKeyboardColorEntry:
	var instance: NutOSContentDesktopAppSettingsMenuKeyboardColorEntry = _a_Color_Entry_Scene.instantiate()
	instance.selected.connect(_on_Color_Entry_selected.bind(instance, p_is_fav_color))
	instance.set_color.call_deferred(p_color)
	if p_selected:
		instance.select.call_deferred()
		_a_selected = instance
	if p_is_fav_color:
		instance.show_fav.call_deferred()
	
	_a_Available.add_child(instance)
	
	return instance

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	var selected_color: Color = _a_selected.get_color()
	data[&"Selected"] = selected_color
	data[&"Fav_Color_Selected"] = _a_fav_color_selected
	
	return data

func load_save_data(p_save_data: Dictionary) -> void:
	var selected: Color
	if p_save_data.is_empty():
		selected = Global_Data.get_fav_color()
		_a_fav_color_selected = true
	else:
		selected = p_save_data[&"Selected"]
		_a_fav_color_selected = p_save_data[&"Fav_Color_Selected"]
	
	_update_available_colors(selected)

func _on_Global_Data_fav_color_changed(_p_color: Color) -> void:
	var selected_color: Color = _a_selected.get_color()
	_update_available_colors(selected_color)

func _on_Color_Entry_selected(p_instance: NutOSContentDesktopAppSettingsMenuKeyboardColorEntry, p_is_fav_color: bool) -> void:
	_a_selected.deselect()
	p_instance.select()
	
	var color: Color = p_instance.get_color()
	color_selected.emit(color, p_is_fav_color)
	_a_selected = p_instance
	_a_fav_color_selected = p_is_fav_color
