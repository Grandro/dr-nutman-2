extends MainMenuSubMenuOptionsOptionTab
class_name MainMenuSubMenuOptionsControls

@onready var _a_Keyboard_Layout: FWDebugValueSelectOptions = get_node("HSplit/Left/Keyboard_Layout")

func _ready() -> void:
	_a_Keyboard_Layout.selected.connect(_on_Keyboard_Layout_selected)
	
	_a_Keyboard_Layout.update_options()

func load_data(p_data: Dictionary) -> void:
	_a_Keyboard_Layout.load_data(p_data[&"Keyboard_Layout"])

func _on_Keyboard_Layout_selected() -> void:
	var keyboard_layout: StringName = _a_Keyboard_Layout.get_selected_key()
	Global_Data.set_options_controls_keyboard_layout(keyboard_layout)
