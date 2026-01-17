extends MarginContainer
class_name CompSpeechBubbleChoicesBox

signal choice_selected(p_value: Variant)

var _a_Choice_Entry_Scene: PackedScene = preload("res://Global_Scenes/Dialogue_System/Choice_Entry.tscn")

@onready var _a_Choices: VBoxContainer = get_node("Margin/Choices")

func _ready() -> void:
	Global_Data.fav_color_changed.connect(_on_Global_Data_fav_color_changed)
	
	hide()

func open(p_args: Dictionary) -> void:
	var pos_type: StringName = p_args[&"Pos"][&"Type"]
	match pos_type:
		&"Left": set_h_size_flags(0)
		&"Center": set_h_size_flags(4)
		&"Right": set_h_size_flags(8)
	
	var global_si: Global = Global.get_singleton(self, "Global")
	var grab_focus_: bool = true
	for args: Dictionary in p_args[&"Entries"].values():
		var conditions: Dictionary = args[&"Conditions"]
		var disabled: bool = false
		for condition_args: Dictionary in conditions.values():
			if !global_si.execute_expr_from_data(condition_args[&"Expression"]):
				disabled = true
				break
		
		var loc_id: StringName = args[&"Loc_ID"][&"Loc_ID"]
		var value: Variant = args[&"Value"]
		
		var instance: Button = _a_Choice_Entry_Scene.instantiate()
		instance.pressed.connect(_on_Choice_Entry_pressed.bind(value))
		instance.set_text(tr(loc_id))
		instance.set_disabled(disabled)
		if grab_focus_ && !disabled:
			instance.grab_focus.call_deferred()
			grab_focus_ = false
		
		_a_Choices.add_child(instance)
	
	var fav_color: Color = Global_Data.get_fav_color()
	_set_choices_font_color.call_deferred(fav_color)
	
	show()

func _set_choices_font_color(p_color: Color) -> void:
	for child: Button in _a_Choices.get_children():
		child.set(&"custom_colors/font_color_focus", p_color)
		child.set(&"custom_colors/font_color_hover", p_color)
		child.set(&"custom_colors/font_color_pressed", p_color)

func _on_Choice_Entry_pressed(p_value: Variant) -> void:
	for child: Button in _a_Choices.get_children():
		child.queue_free()
	
	choice_selected.emit(p_value)
	
	hide()

func _on_Global_Data_fav_color_changed(p_color: Color) -> void:
	_set_choices_font_color(p_color)
