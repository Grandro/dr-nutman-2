extends CanvasLayer
class_name ObjectTutatoCompExplainBase2D

signal completed()

@onready var _a_Background: ColorRect = get_node("Control/Background")
@onready var _a_Parts: Control = get_node("Control/Parts")

func _ready() -> void:
	for child: Container in _a_Parts.get_children():
		child.hide()
	hide()

func init(_p_entities: Array[Node]) -> void:
	pass

func open() -> void:
	pass

func close() -> void:
	completed.emit()
	hide()

func set_background_visible(p_visible: bool) -> void:
	_a_Background.set_visible(p_visible)

func set_part_visible(p_key: String, p_visible: bool) -> void:
	var instance: Container = _a_Parts.get_node(p_key)
	instance.set_visible(p_visible)

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
