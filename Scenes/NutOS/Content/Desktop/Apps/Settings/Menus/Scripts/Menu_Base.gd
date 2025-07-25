extends MarginContainer

signal return_pressed()
signal option_selected(p_key, p_option, p_texture)

@onready var _a_Return = get_node("VBox/Return")

var _a_key = ""

func _ready():
	_a_Return.pressed.connect(_on_Return_pressed)

func open(_p_data):
	pass

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func get_save_data():
	return {}

func _on_Return_pressed():
	return_pressed.emit()
