extends FWDebugValueSelect
class_name FWDebugValueSelectRange

@onready var _a_Value: FWDebugValueSelectRangeEdit = get_node("Value")

func set_max_value_max(p_max_value: float) -> void:
	_a_Value.set_max_value_max(p_max_value)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_Value.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.load_data(p_data[&"Value"])

func load_data_init() -> void:
	super()
	_a_Value.load_data_init()
