extends MarginContainer

@onready var _a_Desc = get_node("HBox/Desc")
@onready var _a_Paint = get_node("HBox/Paint")

func _ready():
	_a_Paint.hide()

func update_trans():
	_a_Desc.set_text(tr("MINIGAMES_COLOR_SELECTION_NEXT_COLOR"))

func show_paint():
	_a_Paint.show()

func set_paint_color(p_color):
	_a_Paint.set_self_modulate(p_color)
