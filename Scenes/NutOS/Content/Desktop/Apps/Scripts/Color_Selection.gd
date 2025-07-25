extends "res://Scenes/NutOS/Content/Desktop/Apps/Scripts/App.gd"

@onready var _a_Color_Selection = get_node("Color_Selection")

func _ready():
	super()
	_a_Color_Selection.closed.connect(_on_Color_Selection_closed)

func open(_p_save_data):
	_a_Color_Selection.open()

func _on_Color_Selection_closed():
	_close()

func _on_close_requested():
	_a_Color_Selection.close()
