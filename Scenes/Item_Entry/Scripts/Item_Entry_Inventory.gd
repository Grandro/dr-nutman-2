extends ItemEntryBase
class_name ItemEntryInventory

signal pressed()

@onready var _a_Amount: Label = get_node("VBox/Margin/Amount")
@onready var _a_Select: Button = get_node("Select")

var _a_name: String
var _a_type: StringName
var _a_amount: int

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)

func grab_select_focus() -> void:
	_a_Select.grab_focus()

func change_amount(p_amount: int) -> void:
	set_amount(_a_amount + p_amount)

func set_name_(p_name: String) -> void:
	_a_name = p_name

func get_name_() -> String:
	return _a_name

func set_type(p_type: StringName) -> void:
	_a_type = p_type

func get_type() -> StringName:
	return _a_type

func set_amount(p_amount: int) -> void:
	_a_amount = p_amount
	_a_Amount.set_text(str(p_amount))
	
	set_visible(p_amount > 0)

func get_amount() -> int:
	return _a_amount

func set_amount_visible(p_visible: bool) -> void:
	_a_Amount.set_visible(p_visible)

func _on_Select_pressed() -> void:
	pressed.emit()
