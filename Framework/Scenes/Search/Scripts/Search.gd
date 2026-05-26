extends MarginContainer
class_name FWSearch

signal input_text_changed(p_text: String)
signal input_text_submitted(p_text: String)
signal input_focus_entered()

@onready var _a_Input: FWJoyLineEdit = get_node("Input")

func _ready() -> void:
	_a_Input.text_changed.connect(_on_Input_text_changed)
	_a_Input.text_submitted.connect(_on_Input_text_submitted)
	_a_Input.focus_entered.connect(_on_Input_focus_entered)

func set_input_text(p_text: String) -> void:
	_a_Input.set_text(p_text)

func get_input_text() -> String:
	return _a_Input.get_text()

func _on_Input_text_changed(p_text: String) -> void:
	input_text_changed.emit(p_text)

func _on_Input_text_submitted(p_text: String) -> void:
	input_text_submitted.emit(p_text)

func _on_Input_focus_entered() -> void:
	input_focus_entered.emit()
