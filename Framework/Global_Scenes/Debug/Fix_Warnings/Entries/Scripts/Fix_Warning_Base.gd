extends HBoxContainer
class_name FWDebugFixWarningsEntryBase

@onready var _a_Value_Keys: Label = get_node("Value_Keys")
@onready var _a_Old_Value: Label = get_node("VBox/Old/Value")

var _a_data: Dictionary # Data of entry instance
var _a_warning: FWDebugCommandEditorEntryCommand.WarningArgsBase # Warning instance
var _a_new_value: Variant = null # New value to apply

func _ready() -> void:
	var value_keys: Array = _a_warning.get_value_keys()
	var value: Variant = _a_warning.get_value()
	_a_Value_Keys.set_text(str(value_keys))
	_a_Old_Value.set_text(str(value))

func apply_changes() -> void:
	if _a_new_value == null:
		return
	
	var value_keys: Array = _a_warning.get_value_keys()
	var last: Variant = value_keys[-1]
	var dic: Dictionary = _a_data
	for i: int in value_keys.size() - 1:
		var key: Variant = value_keys[i]
		dic = dic[key]
	dic[last] = _a_new_value

func set_data(p_data: Dictionary) -> void:
	_a_data = p_data

func set_warning(p_warning: FWDebugCommandEditorEntryCommand.WarningArgsBase) -> void:
	_a_warning = p_warning
