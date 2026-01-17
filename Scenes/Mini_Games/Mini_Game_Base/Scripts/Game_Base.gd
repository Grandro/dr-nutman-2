extends Node2D
class_name MiniGameGameBase

signal finished()

@onready var _a_Background: TextureRect = get_node("Canvas_1/Background")

func _ready() -> void:
	_a_Background.hide()
	hide()

func open() -> void:
	_a_Background.show()
	show()

func close() -> void:
	_a_Background.hide()
	hide()
	
	finished.emit()
