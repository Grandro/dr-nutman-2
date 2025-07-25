extends MarginContainer

signal color_selected(p_color)

var _a_Prev_Color_Entry_Scene = load("res://Scenes/Mini_Games/Color_Selection/Game/Prev_Color_Entry.tscn")

@onready var _a_Heading = get_node("VBox/Heading")
@onready var _a_HFlow = get_node("VBox/Scroll/HFlow")

var _a_selected = null # Selected Prev_Color_Entry

func update_trans():
	_a_Heading.set_text(tr("MINIGAMES_COLOR_SELECTION_PREVCOLORS"))

func open(p_color):
	var has_theme_color_ = false
	var data = Global_Data.get_entry_data("Fav_Color")
	var prev_colors = data["Prev"]
	for color in prev_colors:
		var instance = _instantiate_prev_color_entry(color, false)
		_a_HFlow.add_child(instance)
		if color == p_color:
			has_theme_color_ = true
			_a_selected = instance
	
	if !has_theme_color_:
		var instance = _instantiate_prev_color_entry(p_color, true)
		_a_HFlow.add_child(instance)
		_a_selected = instance
	
	_a_selected.set_deletable(false)
	show()

func close():
	var entry_data = {}
	entry_data["Selected"] = _a_selected.get_self_color()
	
	var prev_colors = []
	for child in _a_HFlow.get_children():
		var color = child.get_self_color()
		prev_colors.push_back(color)
		child.queue_free()
	entry_data["Prev"] = prev_colors
	
	Global_Data.set_entry_data("Fav_Color", entry_data)
	Global_Data.save_data()
	
	hide()

func _instantiate_prev_color_entry(p_color, p_visible):
	var instance = _a_Prev_Color_Entry_Scene.instantiate()
	instance.pressed.connect(_on_Prev_Color_Entry_pressed.bind(instance))
	instance.delete_pressed.connect(_on_Prev_Color_Entry_delete_pressed.bind(instance))
	instance.set_self_color.call_deferred(p_color)
	instance.set_new_visible.call_deferred(p_visible)
	
	return instance

func MESSAGES_PROCEED(p_response, p_instance):
	if p_response == "Yes":
		p_instance.queue_free()

func _on_Prev_Color_Entry_pressed(p_instance):
	_a_selected.set_deletable(true)
	p_instance.set_deletable(false)
	_a_selected = p_instance
	
	var color = p_instance.get_self_color()
	color_selected.emit(color)

func _on_Prev_Color_Entry_delete_pressed(p_instance):
	var messages_si = Global.get_singleton(self, "Messages")
	messages_si.show_proceed(tr("CONFIRM_DELETE_COLOR"), self, p_instance)
