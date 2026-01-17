extends NutOSContentDesktopAppSettingsMenuBase
class_name NutOSContentDesktopAppSettingsMenuKeyboard

@onready var _a_Tab_Colors: Button = get_node("VBox/HBox/Tabs/Colors")
@onready var _a_Content_Colors: NutOSContentDesktopAppSettingsMenuKeyboardColors = get_node("VBox/HBox/Content/Colors")

func _ready() -> void:
	super()
	_a_Tab_Colors.pressed.connect(_on_Tab_Colors_pressed)
	_a_Content_Colors.static_color_selected.connect(_on_Content_Colors_static_color_selected)

func open(p_data: Dictionary) -> void:
	var color_data: Dictionary = {}
	if !p_data.is_empty():
		color_data = p_data[&"Colors"]
	_a_Content_Colors.open(color_data)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Colors"] = _a_Content_Colors.get_save_data()
	
	return data

func _on_Tab_Colors_pressed() -> void:
	_a_Content_Colors.show()

func _on_Content_Colors_static_color_selected(p_color: Color, p_is_fav_color: bool) -> void:
	option_selected.emit(&"Settings_Keyboard", &"Static_Color", [p_color, p_is_fav_color])
