extends MainMenuSubMenuOptionsOptionTab
class_name MainMenuSubMenuOptionsGameplay

@onready var _a_Show_Tutato_Explain: FWDebugValueSelectBool = get_node("HSplit/Left/Show_Tutato_Explain")

func _ready() -> void:
	_a_Show_Tutato_Explain.toggled.connect(_on_Show_Tutato_Explain_toggled)

func load_data(p_data: Dictionary) -> void:
	_a_Show_Tutato_Explain.load_data(p_data[&"Show_Tutato_Explain"])

func _on_Show_Tutato_Explain_toggled(p_toggled: bool) -> void:
	Global_Data.set_options_gameplay_show_tutato_explain(p_toggled)
