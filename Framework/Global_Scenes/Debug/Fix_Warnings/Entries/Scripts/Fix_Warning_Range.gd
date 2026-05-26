extends FWDebugFixWarningsEntryBase
class_name FWDebugFixWarningsEntryRange

@onready var _a_Range: FWDebugRangeEdit = get_node("VBox/New/Range")

var _a_min_value: float # New min value
var _a_max_value: float # New max value
var _a_min_value_changed: bool = false
var _a_max_value_changed: bool = false

func _ready() -> void:
	super()
	_a_Range.min_value_changed.connect(_on_Range_min_value_changed)
	_a_Range.max_value_changed.connect(_on_Range_max_value_changed)
	
	var min_value: float = _a_Range.get_min_value()
	var max_value: float = _a_Range.get_max_value()
	var min_: int = _a_warning.get_min()
	var max_: int = _a_warning.get_max()
	_a_Range.set_min_min(min_)
	_a_Range.set_min_max(max_value)
	_a_Range.set_max_min(min_value)
	_a_Range.set_max_max(max_)

func apply_changes() -> void:
	if !_a_min_value_changed || !_a_max_value_changed:
		return
	
	var value_keys: Array = _a_warning.get_value_keys()
	for i: int in value_keys.size():
		var args: Array[StringName] = value_keys[i]
		var last: StringName = args[-1]
		var dic: Dictionary = _a_data
		for j: int in args.size() - 1:
			var key: StringName = args[j]
			dic = dic[key]
		
		match i:
			0: dic[last] = _a_min_value
			1: dic[last] = _a_max_value

func _on_Range_min_value_changed(p_value: float) -> void:
	_a_min_value = p_value
	_a_min_value_changed = true

func _on_Range_max_value_changed(p_value: float) -> void:
	_a_max_value = p_value
	_a_max_value_changed = true
