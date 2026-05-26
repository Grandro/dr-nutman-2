extends Control
class_name FWItemSelectBaseMenu

@onready var _a_Back: FWIndicatorButton = get_node("Back")

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)

func close() -> void:
	hide()

func _on_Back_select_pressed() -> void:
	close()
