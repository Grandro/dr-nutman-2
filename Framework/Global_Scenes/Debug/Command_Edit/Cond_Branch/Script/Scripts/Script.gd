extends FWDebugCommandEditMenuBase
class_name FWDebugCommandEditCommandCondBranchScript

@onready var _a_Expression: FWDebugExpressionBase = get_node("Expression")

func get_save_data() -> Dictionary:
	return _a_Expression.get_save_data()

func load_data(p_data: Dictionary) -> void:
	_a_Expression.update_instances()
	super(p_data)

func _load_data_init() -> void:
	_a_Expression.load_data_init()

func _load_data(p_data: Dictionary) -> void:
	_a_Expression.load_data(p_data)
