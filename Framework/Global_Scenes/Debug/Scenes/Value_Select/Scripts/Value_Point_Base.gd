extends FWDebugValueSelect
class_name FWDebugValueSelectPointBase

@export var _e_type_texture: Texture2D = preload("uid://dt70asssy8c3g")
@export var _e_point_scene: PackedScene = null

@onready var _a_Value_Text: Label = get_node("Value/Margin/Text")
@onready var _a_Value_Type: TextureRect = get_node("Value/Margin/Type")

var _a_point: Node = null # Point instance displayed on map
var _a_point_vec: Variant = null # Coords of _a_point in grid

func _ready() -> void:
	super()
	_a_Value_Type.set_texture(_e_type_texture)
	
	_instantiate_point()
	_a_point.hide()

func _instantiate_point() -> void:
	_a_point = _e_point_scene.instantiate()
	_a_point.set_texture(_e_type_texture)

func _update_value_text() -> void:
	if !is_point_visible():
		_a_Value_Text.set_text("-")

func get_point_instance() -> Node:
	return _a_point

func set_point_vec(p_point_vec: Variant) -> void:
	_a_point_vec = p_point_vec

func get_point_vec() -> Variant:
	return _a_point_vec

func get_point_pos() -> Variant:
	return _a_point.get_position()

func set_point_visible(p_visible: bool) -> void:
	_a_point.set_visible(p_visible)
	_update_value_text()

func is_point_visible() -> bool:
	return _a_point.is_visible()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Selected"] = is_point_visible()
	data[&"Value"] = get_point_vec()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var selected: bool = p_data[&"Selected"]
	set_point_vec(p_data[&"Value"])
	set_point_visible(selected)

func load_data_init() -> void:
	super()
	_a_Value_Text.set_text("-")
