extends MarginContainer
class_name SVEncounterSpecialsMenuEntry

signal select_pressed()
signal select_focus_entered()

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Name: Label = get_node("Margin/HBox/Name")
@onready var _a_SP_Cost_Text: Label = get_node("Margin/HBox/SP_Cost/Text")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.focus_entered.connect(_on_Select_focus_entered)

func grab_select_focus() -> void:
	_a_Select.grab_focus()

func set_name_text(p_text: String) -> void:
	_a_Name.set_text(p_text)

func set_SP_cost(p_SP_cost: int) -> void:
	_a_SP_Cost_Text.set_text(str(p_SP_cost))

func _on_Select_pressed() -> void:
	select_pressed.emit()

func _on_Select_focus_entered() -> void:
	select_focus_entered.emit()
