extends MarginContainer
class_name MiniGameColorSelectionPrevColors

signal color_selected(p_color: Color)

var _a_Prev_Color_Entry_Scene: PackedScene = load("uid://18ymogmt1iqx")

@onready var _a_HFlow: HFlowContainer = get_node("VBox/Scroll/HFlow")

var _a_selected: MiniGameColorSelectionPrevColorEntry # Selected Prev_Color_Entry

func open(p_color: Color) -> void:
	var has_theme_color_: bool = false
	var data: Dictionary = Global_Data.get_entry_data(&"Fav_Color")
	var prev_colors: PackedColorArray = data[&"Prev"]
	for color: Color in prev_colors:
		var instance: MiniGameColorSelectionPrevColorEntry = _instantiate_prev_color_entry(color, false)
		_a_HFlow.add_child(instance)
		if color == p_color:
			has_theme_color_ = true
			_a_selected = instance
	
	if !has_theme_color_:
		var instance: MiniGameColorSelectionPrevColorEntry = _instantiate_prev_color_entry(p_color, true)
		_a_HFlow.add_child(instance)
		_a_selected = instance
	
	_a_selected.set_deletable(false)
	show()

func close() -> void:
	var entry_data: Dictionary = {}
	entry_data[&"Selected"] = _a_selected.get_self_color()
	
	var prev_colors: PackedColorArray = PackedColorArray()
	var size_: int = _a_HFlow.get_child_count()
	prev_colors.resize(size_)
	for i: int in size_:
		var child: MiniGameColorSelectionPrevColorEntry = _a_HFlow.get_child(i)
		var color: Color = child.get_self_color()
		prev_colors[i] = color
		child.queue_free()
	entry_data[&"Prev"] = prev_colors
	
	Global_Data.set_entry_data(&"Fav_Color", entry_data)
	Global_Data.save_data()
	
	hide()

func _instantiate_prev_color_entry(p_color: Color, p_visible: bool) -> MiniGameColorSelectionPrevColorEntry:
	var instance: MiniGameColorSelectionPrevColorEntry = _a_Prev_Color_Entry_Scene.instantiate()
	instance.pressed.connect(_on_Prev_Color_Entry_pressed.bind(instance))
	instance.delete_pressed.connect(_on_Prev_Color_Entry_delete_pressed.bind(instance))
	instance.set_self_color.call_deferred(p_color)
	instance.set_new_visible.call_deferred(p_visible)
	
	return instance

func _on_Prev_Color_Entry_pressed(p_instance: MiniGameColorSelectionPrevColorEntry) -> void:
	_a_selected.set_deletable(true)
	p_instance.set_deletable(false)
	_a_selected = p_instance
	
	var color: Color = p_instance.get_self_color()
	color_selected.emit(color)

func _on_Prev_Color_Entry_delete_pressed(p_instance: MiniGameColorSelectionPrevColorEntry) -> void:
	var messages_si: Messages = Global.get_singleton(self, "Messages")
	messages_si.show_proceed(tr(&"CONFIRM_DELETE_COLOR"), _CB_Messages_Proceed.bind(p_instance))

func _CB_Messages_Proceed(p_response: StringName, p_instance: MiniGameColorSelectionPrevColorEntry) -> void:
	if p_response == &"Yes":
		p_instance.queue_free()
