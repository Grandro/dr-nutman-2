extends MarginContainer
class_name DebugValueEdit

signal value_changed(p_value: Variant)

const _a_TYPE_SCENE_PATH: String = "res://Global_Scenes/Debug/Scenes/Value_Edit/Types/%s.tscn"

@export var _e_type_keys: Dictionary[Variant.Type, String] = {}
@export var _e_data: ValueEditData
@export var _e_colors: Array[Color] = []

@onready var _a_Text_Panel: PanelContainer = get_node("HBox/Text")
@onready var _a_Text: Label = get_node("HBox/Text/Margin/Scroll/Value")
@onready var _a_Type: MarginContainer = get_node("HBox/Type")
@onready var _a_VSep: VSeparator = get_node("HBox/VSep")
@onready var _a_Edit: DebugValueEditEdit = get_node("HBox/Edit")
@onready var _a_Focus_Outlines: Panel = get_node("Focus_Outlines")

var _a_instance # Current type instance
var _a_color_idx: int = 0
var _a_init: bool = true

func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	_a_Edit.type_changed.connect(_on_Edit_type_changed)
	_a_Edit.remove_item_pressed.connect(_on_Edit_remove_item_pressed)
	
	if _e_data == null:
		_e_data = ValueEditData.new()
	
	var type: Variant.Type = get_type()
	var type_editable: bool = get_type_editable()
	var removable: bool = get_removable()
	_a_Edit.update_types(_e_type_keys, type_editable, removable)
	_a_Text_Panel.hide()
	_a_Focus_Outlines.hide()
	
	if !_a_init:
		return
	
	_a_instance = _instantiate_type(type)
	_a_Type.add_child(_a_instance)
	if type == TYPE_ARRAY || type == TYPE_DICTIONARY:
		_a_instance.set_data(_e_data.duplicate(true))
	_a_instance.set_value(get_value())
	
	_to_color(_e_colors[_a_color_idx])
	
	if !type_editable && !removable:
		_a_VSep.hide()
		_a_Edit.hide()

func expand(p_depth: int) -> void:
	_a_instance.expand(p_depth)

func delete() -> void:
	_delete_type()
	queue_free()

func _delete_type() -> void:
	if _a_instance != null:
		_a_instance.value_changed.disconnect(_on_Type_value_changed)
		_a_instance.delete.call_deferred()

func show_text() -> void:
	_a_Text_Panel.show()

func _instantiate_type(p_type: Variant.Type):
	var key: String = _e_type_keys[p_type]
	var scene: PackedScene = load(_a_TYPE_SCENE_PATH % key)
	var instance = scene.instantiate()
	instance.value_changed.connect(_on_Type_value_changed)
	instance.set_value_editable.call_deferred(get_value_editable())
	instance.set_expanded.call_deferred(get_expanded())
	instance.to_color.call_deferred(_e_colors[_a_color_idx])
	
	if p_type == TYPE_ARRAY || p_type == TYPE_DICTIONARY:
		var color_idx: int = (_a_color_idx + 1) % _e_colors.size()
		instance.set_color_idx(color_idx)
	
	return instance

func _to_color(_p_color: Color) -> void:
	pass

func set_instance_default_value() -> void:
	_a_instance.set_default_value()

func set_text(p_text: String) -> void:
	_a_Text.set_text(p_text)

func get_text() -> String:
	return _a_Text.get_text()

func set_value(p_value: Variant) -> void:
	match typeof(p_value):
		TYPE_ARRAY: p_value = p_value.duplicate(true)
		TYPE_DICTIONARY: p_value = p_value.duplicate(true)
	
	_e_data.set_value(p_value)
	_set_value(p_value)

func _set_value(p_value: Variant) -> void:
	var type: Variant.Type = typeof(p_value) as Variant.Type
	if !_e_type_keys.has(type):
		print("Value_Edit doesn't support type of: ", type, " with value ", p_value)
		return
	
	_delete_type()
	_a_instance = _instantiate_type(type)
	_a_Type.add_child(_a_instance)
	if type == TYPE_ARRAY || type == TYPE_DICTIONARY:
		_a_instance.set_data(_e_data.duplicate(true))
	_a_instance.set_value(get_value())

func get_value() -> Variant:
	var value: Variant = _e_data.get_value()
	match typeof(value):
		TYPE_ARRAY: value = value.duplicate(true)
		TYPE_DICTIONARY: value = value.duplicate(true)
	
	return value

func set_data(p_data: ValueEditData) -> void:
	if p_data == null:
		return
	
	_e_data = p_data
	_set_data.call_deferred(p_data)

func _set_data(p_data: ValueEditData) -> void:
	_set_value(p_data.get_value())
	_set_type_editable(p_data.get_type_editable())
	_set_value_editable(p_data.get_value_editable())

func get_type() -> Variant.Type:
	return _e_data.get_type()

func set_type_editable(p_type_editable: bool) -> void:
	_e_data.set_type_editable(p_type_editable)
	_set_type_editable(p_type_editable)

func _set_type_editable(p_type_editable: bool) -> void:
	var removable: bool = get_removable()
	_a_Edit.update_types(_e_type_keys, p_type_editable, removable)
	_a_VSep.set_visible(p_type_editable || removable)
	_a_Edit.set_visible(p_type_editable || removable)

func get_type_editable() -> bool:
	return _e_data.get_type_editable()

func set_value_editable(p_value_editable: bool) -> void:
	_e_data.set_value_editable(p_value_editable)
	_set_value_editable(p_value_editable)

func _set_value_editable(p_value_editable: bool) -> void:
	_a_instance.set_value_editable(p_value_editable)

func get_value_editable() -> bool:
	return _e_data.get_value_editable()

func get_expanded() -> bool:
	return _e_data.get_expanded()

func set_removable(p_removable: bool) -> void:
	_e_data.set_removable(p_removable)
	_a_Edit.update_types(_e_type_keys, get_type_editable(), p_removable)

func get_removable() -> bool:
	return _e_data.get_removable()

func set_color_idx(p_color_idx: int) -> void:
	_a_color_idx = p_color_idx

func set_init(p_init: bool) -> void:
	_a_init = p_init

func _on_focus_entered() -> void:
	_a_Focus_Outlines.show()

func _on_focus_exited() -> void:
	_a_Focus_Outlines.hide()

func _on_Type_value_changed(p_value: Variant) -> void:
	_e_data.set_value(p_value)
	value_changed.emit(p_value)

func _on_Edit_type_changed(p_type: Variant.Type) -> void:
	_delete_type()
	_a_instance = _instantiate_type(p_type)
	_a_Type.add_child(_a_instance)
	
	match p_type:
		TYPE_ARRAY:
			_e_data.set_value([])
			_a_instance.set_data(_e_data.duplicate(true))
		TYPE_DICTIONARY:
			_e_data.set_value({})
			_a_instance.set_data(_e_data.duplicate(true))
		_:
			var value: Variant = _a_instance.get_value()
			_e_data.set_value(value)
	_a_instance.set_value(get_value())
	
	value_changed.emit(get_value())

func _on_Edit_remove_item_pressed() -> void:
	_delete_type()
	queue_free()
