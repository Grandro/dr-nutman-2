extends DebugEntryListEntry
class_name DebugEntryListExpressionEntry

@onready var _a_Expression: DebugExpressionBase = get_node("HBox/VBox/Options/Expression")

func update_expression_self(p_self_key: StringName) -> void:
	_a_Expression.update_self(p_self_key)

func update_expression_instances() -> void:
	_a_Expression.update_instances()

func load_expression_data(p_data: Dictionary) -> void:
	if p_data.is_empty():
		_a_Expression.load_data_init()
	else:
		_a_Expression.load_data(p_data)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Expression"] = _a_Expression.get_save_data()
	data[&"Expression_Self_Key"] = _a_Expression.get_self_key()
	
	return data
