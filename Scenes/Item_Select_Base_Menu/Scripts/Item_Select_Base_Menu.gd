extends Control
class_name ItemSelectBaseMenu

@onready var _a_Back: IndicatorButton = get_node("Back")

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)

func update_trans() -> void:
	pass

func close() -> void:
	hide()

func _on_Back_select_pressed() -> void:
	close()
