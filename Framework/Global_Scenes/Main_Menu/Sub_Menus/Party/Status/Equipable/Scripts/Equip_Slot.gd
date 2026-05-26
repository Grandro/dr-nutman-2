extends FWItemDragMenuBaseSlot
class_name MainMenuSubMenuPartyStatusEquipableEquipSlot

@export var _e_group: StringName = &""

@onready var _a_BG_Icon: TextureRect = get_node("BG_Icon")

func _ready() -> void:
	var item_type_icon_path: String = Global.get_item_type_icon_path()
	var texture: Texture2D = load(item_type_icon_path % ["Equipment", _e_group])
	_a_BG_Icon.set_texture(texture)

func insert_(p_item_key: StringName, p_pm_key: StringName, p_group: StringName, p_update: bool) -> void:
	insert(p_item_key)
	_a_BG_Icon.hide()
	
	if p_update:
		var global_si: Global = Global.get_singleton(self, "Global")
		global_si.equip_party_member(p_pm_key, p_group, p_item_key)

func remove_(p_pm_key: StringName, p_group: StringName, p_update: bool) -> void:
	remove()
	_a_BG_Icon.show()
	
	if p_update:
		var global_si: Global = Global.get_singleton(self, "Global")
		global_si.unequip_party_member(p_pm_key, p_group)

func get_group() -> StringName:
	return _e_group
