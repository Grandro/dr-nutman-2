extends CanvasLayer

signal completed()

@onready var _a_Background = get_node("Control/Background")
@onready var _a_Parts = get_node("Control/Parts")

func _ready():
	for child in _a_Parts.get_children():
		child.hide()
	hide()

func init(_p_entity):
	pass

func open():
	pass

func close():
	completed.emit()
	hide()

func set_background_visible(p_visible):
	_a_Background.set_visible(p_visible)

func set_part_visible(p_key, p_visible):
	var instance = _a_Parts.get_node(p_key)
	instance.set_visible(p_visible)

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
