extends DebugCommandEditMenuBase
class_name DebugCommandEditCommandCondBranchItems

@onready var _a_Item: DebugItemSelect = get_node("VBox/Item")
@onready var _a_Amount: DebugValueSelectRange = get_node("VBox/Amount")

func _ready() -> void:
	_a_Item.selected.connect(_on_Item_selected)

func _selected_item_changed() -> void:
	var key: StringName = _a_Item.get_key()
	if key == &"":
		_a_Amount.set_max_value_max(0)
	else:
		var stack: int = _a_Item.get_stack_()
		_a_Amount.set_max_value_max(stack)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Item"] = _a_Item.get_save_data()
	data[&"Amount"] = _a_Amount.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_selected_item_changed()

func _load_data_init() -> void:
	_a_Item.load_data_init()
	_a_Amount.load_data_init()

func _load_data(p_data: Dictionary) -> void:
	_a_Item.load_data(p_data[&"Item"])
	_a_Amount.load_data(p_data[&"Amount"])

func _on_Item_selected() -> void:
	_selected_item_changed()
