extends "res://Scenes/Mini_Games/Mini_Game_Base/Scripts/Game_Base.gd"

@onready var _a_QT_Bar = get_node("Canvas_2/QT_Bar")

var _a_diff = 0

func open_qt_bar(p_preview):
	_a_QT_Bar.open(_a_diff, p_preview)

func close_qt_bar():
	_a_QT_Bar.close()
