extends FWMiniGameGameBase
class_name MiniGameRightOnTheNutGameBase

@onready var _a_QT_Bar: MiniGameRightOnTheNutQTBar = get_node("Canvas_2/QT_Bar")

var _a_diff: int = 0

func open_qt_bar(p_preview: bool) -> void:
	_a_QT_Bar.open(_a_diff, p_preview)

func close_qt_bar() -> void:
	_a_QT_Bar.close()
