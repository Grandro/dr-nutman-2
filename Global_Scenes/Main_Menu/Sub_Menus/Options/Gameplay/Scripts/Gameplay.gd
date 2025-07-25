extends "res://Global_Scenes/Main_Menu/Sub_Menus/Options/Scripts/Option_Tab.gd"

@onready var _a_Show_Tutato_Explain = get_node("HSplit/Left/Show_Tutato_Explain")

func _ready():
	_a_Show_Tutato_Explain.toggled.connect(_on_Show_Tutato_Explain_toggled)

func load_data(p_data):
	_a_Show_Tutato_Explain.load_data(p_data["Show_Tutato_Explain"])

func _on_Show_Tutato_Explain_toggled(p_toggled):
	Global_Data.set_options_gameplay_show_tutato_explain(p_toggled)
