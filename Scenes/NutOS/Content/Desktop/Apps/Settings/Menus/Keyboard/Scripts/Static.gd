extends VBoxContainer

signal color_selected(p_color, p_is_fav_color)

var _a_Color_Entry_Scene = preload("res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Keyboard/Color_Entry.tscn")

@onready var _a_Available = get_node("Available/HFlow")

var _a_selected = null
var _a_fav_color_selected = false

func _ready():
	Global_Data.fav_color_changed.connect(_on_Global_Data_fav_color_changed)
	
	hide()

func _update_available_colors(p_selected):
	for child in _a_Available.get_children():
		child.queue_free()
	
	var data = Global_Data.get_entry_data("Fav_Color")
	var prev = data["Prev"]
	var fav_color = data["Selected"]
	var fav_instance = _instantiate_available_color(fav_color, _a_fav_color_selected, true)
	
	var was_selected = _a_fav_color_selected
	for color in prev:
		var selected = false
		if !_a_fav_color_selected && color == p_selected:
			selected = true
			was_selected = true
		_instantiate_available_color(color, selected, false)
	
	if !was_selected:
		fav_instance.select.call_deferred()
		_a_selected = fav_instance
		color_selected.emit(fav_color, true)

func _instantiate_available_color(p_color, p_selected, p_is_fav_color):
	var instance = _a_Color_Entry_Scene.instantiate()
	instance.selected.connect(_on_Color_Entry_selected.bind(instance, p_is_fav_color))
	instance.set_color.call_deferred(p_color)
	if p_selected:
		instance.select.call_deferred()
		_a_selected = instance
	if p_is_fav_color:
		instance.show_fav.call_deferred()
	
	_a_Available.add_child(instance)
	
	return instance

func get_save_data():
	var data = {}
	var selected_color = _a_selected.get_color()
	data["Selected"] = selected_color
	data["Fav_Color_Selected"] = _a_fav_color_selected
	
	return data

func load_save_data(p_save_data):
	var selected = Color.WHITE
	if p_save_data.is_empty():
		selected = Global_Data.get_fav_color()
		_a_fav_color_selected = true
	else:
		selected = p_save_data["Selected"]
		_a_fav_color_selected = p_save_data["Fav_Color_Selected"]
	
	_update_available_colors(selected)

func _on_Global_Data_fav_color_changed(_p_color):
	var selected_color = _a_selected.get_color()
	_update_available_colors(selected_color)

func _on_Color_Entry_selected(p_instance, p_is_fav_color):
	_a_selected.deselect()
	p_instance.select()
	
	var color = p_instance.get_color()
	color_selected.emit(color, p_is_fav_color)
	_a_selected = p_instance
	_a_fav_color_selected = p_is_fav_color
