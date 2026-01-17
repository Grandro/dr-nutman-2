extends MarginContainer
class_name MiniGameColorSelectionNextColor

@onready var _a_Desc: Label = get_node("HBox/Desc")
@onready var _a_Paint: TextureRect = get_node("HBox/Paint")

func _ready() -> void:
	_a_Paint.hide()

func update_trans() -> void:
	_a_Desc.set_text(tr(&"MINIGAMES_COLOR_SELECTION_NEXT_COLOR"))

func show_paint() -> void:
	_a_Paint.show()

func set_paint_color(p_color: Color) -> void:
	_a_Paint.set_self_modulate(p_color)
