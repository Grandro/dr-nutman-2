extends ItemEntryInventory
class_name ItemEntryLoot

@onready var _a_Name: Label = get_node("VBox/Name")

func set_name_(p_name: String) -> void:
	super(p_name)
	_a_Name.set_text(p_name)
