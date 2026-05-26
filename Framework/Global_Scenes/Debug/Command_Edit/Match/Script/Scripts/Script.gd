extends FWDebugCommandEditMenuMatch
class_name FWDebugCommandEditCommandMatchScript

@onready var _a_Expression: FWDebugExpressionBase = get_node("Expression")

func _ready() -> void:
	_a_Expression.update_instances()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Expression"] = _a_Expression.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_Expression.update_instances()
	super(p_data)

func _load_data_init() -> void:
	_a_Expression.load_data_init()

func _load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Expression.load_data(p_data[&"Expression"])
