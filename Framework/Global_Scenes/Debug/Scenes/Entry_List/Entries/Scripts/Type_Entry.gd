extends FWDebugEntryListEntry
class_name FWDebugEntryListTypeEntry

signal type_changing()
signal type_changed()

@onready var _a_Types: OptionButton = get_node("HBox/VBox/Options/Types")

var _a_types: Dictionary[StringName, int] = {} # Match type to idx
var _a_type: StringName
var _a_data: Dictionary[StringName, Variant] # Match type to data

func _ready() -> void:
	super()
	_a_Types.item_selected.connect(_on_Types_item_selected)

func select_type(p_type: StringName) -> void:
	var idx: int = _a_types[p_type]
	_a_Types.select(idx)
	_a_type = _a_Types.get_selected_metadata()

func set_types(p_types: Array[StringName]) -> void:
	for i: int in p_types.size():
		var type: StringName = p_types[i]
		_a_types[type] = i
		_a_Types.add_item(type)
		_a_Types.set_item_metadata(i, type)
	
	_a_type = _a_Types.get_selected_metadata()

func get_type() -> StringName:
	return _a_type

func set_data(p_data: Dictionary[StringName, Variant]) -> void:
	_a_data = p_data

func get_data() -> Dictionary[StringName, Variant]:
	return _a_data

func set_data_type(p_type: StringName, p_data: Variant) -> void:
	_a_data[p_type] = p_data

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Type"] = _a_type
	data[&"Data"] = _a_data
	
	return data

func _on_Types_item_selected(p_idx: int) -> void:
	type_changing.emit()
	_a_type = _a_Types.get_item_metadata(p_idx)
	type_changed.emit()
