extends Resource
class_name ValueEditData

@export var _e_value: Variant
@export var _e_type_editable: bool = true
@export var _e_value_editable: bool = true
@export var _e_expanded: bool = false
@export var _e_removable: bool = true

@export var _e_fb_child_data: ValueEditData
@export var _e_arr_child_data: Array[ValueEditData] = []
@export var _e_dic_child_data: Dictionary[Variant, ValueEditData] = {}

func set_value(p_value: Variant) -> void:
	_e_value = p_value

func get_value() -> Variant:
	return _e_value

func get_type() -> Variant.Type:
	return typeof(_e_value) as Variant.Type

func set_type_editable(p_type_editable: bool) -> void:
	_e_type_editable = p_type_editable

func get_type_editable() -> bool:
	return _e_type_editable

func set_value_editable(p_value_editable: bool) -> void:
	_e_value_editable = p_value_editable

func get_value_editable() -> bool:
	return _e_value_editable

func set_expanded(p_expanded: bool) -> void:
	_e_expanded = p_expanded

func get_expanded() -> bool:
	return _e_expanded

func set_removable(p_removable: bool) -> void:
	_e_removable = p_removable

func get_removable() -> bool:
	return _e_removable

func get_arr_child_data() -> Array[ValueEditData]:
	return _e_arr_child_data

func get_arr_child_data_idx(p_idx: int) -> ValueEditData:
	if _e_arr_child_data.size() > p_idx:
		return _e_arr_child_data[p_idx]
	if _e_fb_child_data != null:
		return _e_fb_child_data.duplicate(true)
	
	return ValueEditData.new()

func get_dic_child_data() -> Dictionary[Variant, ValueEditData]:
	return _e_dic_child_data

func get_dic_child_data_key(p_key: Variant) -> ValueEditData:
	if _e_dic_child_data.has(p_key):
		return _e_dic_child_data[p_key]
	if _e_fb_child_data != null:
		return _e_fb_child_data
	
	return ValueEditData.new()
