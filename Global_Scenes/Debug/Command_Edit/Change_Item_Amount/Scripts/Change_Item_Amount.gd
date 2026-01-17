extends DebugCommandEditCommandBase
class_name DebugCommandEditCommandChangeItemAmount

@onready var _a_Type: DebugValueSelectOptions = get_node("Window/Contents/Margin/VBox/Type")
@onready var _a_Item: DebugItemSelect = get_node("Window/Contents/Margin/VBox/Item")
@onready var _a_Amount: DebugValueSelectNum = get_node("Window/Contents/Margin/VBox/Amount")

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()
	
	_a_Item.selected.connect(_on_Item_selected)
	
	_a_Type.update_options()

func open(p_instance: DebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data: Dictionary) -> void:
	_a_Type.load_data_init()
	_a_Item.load_data_init()
	_a_Amount.load_data_init()

func _open_load(p_data: Dictionary, _p_res_data: Dictionary) -> void:
	_a_Type.load_data(p_data[&"Type"])
	_a_Item.load_data(p_data[&"Item"])
	_selected_item_changed()
	_a_Amount.load_data(p_data[&"Amount"])

func _selected_item_changed() -> void:
	var key: StringName = _a_Item.get_key()
	if key == &"":
		_a_Amount.set_value_max(0)
	else:
		var stack: int = _a_Item.get_stack_()
		_a_Amount.set_value_max(stack)

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Type"] = _a_Type.get_save_data()
	data[&"Item"] = _a_Item.get_save_data()
	data[&"Amount"] = _a_Amount.get_save_data()
	
	return data

func _on_Item_selected() -> void:
	_selected_item_changed()
