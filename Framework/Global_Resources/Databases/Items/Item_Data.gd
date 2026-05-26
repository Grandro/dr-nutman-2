extends Resource
class_name FWItemData

@export var _e_key: StringName = &""
@export var _e_type: StringName = &"General"
@export var _e_group: StringName = &"Main"
@export var _e_category_type: StringName = &"Consumable"
@export var _e_stack: int = -1

func get_name_() -> String:
	var name_loc_id: String = Databases.get_item_name_loc_id()
	var type_upper: String = _e_type.to_upper()
	var key_upper: String = _e_key.to_upper()
	var name_: String = tr(name_loc_id % [type_upper, key_upper])
	
	return name_

func get_desc() -> String:
	var desc_loc_id: String = Databases.get_item_desc_loc_id()
	var type_upper: String = _e_type.to_upper()
	var key_upper: String = _e_key.to_upper()
	var desc: String = tr(desc_loc_id % [type_upper, key_upper])
	
	return desc

func get_type() -> StringName:
	return _e_type

func get_group() -> StringName:
	return _e_group

func get_category_type() -> StringName:
	return _e_category_type

func get_stack_() -> int:
	return _e_stack

func get_texture() -> Texture2D:
	var item_path: String = Global.get_item_path()
	var texture: Texture2D = load(item_path % _e_key)
	
	return texture
