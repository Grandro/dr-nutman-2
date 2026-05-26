extends FWItemSelectInventory
class_name FWItemSelectInventoryStatus

@onready var _a_Info_Equipped: FWItemSelectInfo = get_node("Grid/HBox/Info_Equipped")

func display_info_equipped(p_key: StringName) -> void:
	_a_Info_Equipped.display(p_key)

func close_info_equipped() -> void:
	_a_Info_Equipped.close()
