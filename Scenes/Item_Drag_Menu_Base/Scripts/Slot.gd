extends PanelContainer
class_name ItemDragMenuBaseSlot

signal inserted(p_item_key: StringName, p_mute: bool)
signal removed()

@onready var _a_Item_Icon: TextureRect = get_node("Item_Icon")

var _a_item_key: StringName = &""

func insert(p_item_key: StringName, p_mute: bool = false) -> void:
	_a_item_key = p_item_key
	
	var item_path: String = Global.get_item_path()
	var texture: Texture2D = load(item_path % p_item_key)
	_a_Item_Icon.set_texture(texture)
	
	inserted.emit(p_item_key, p_mute)

func remove() -> void:
	_a_item_key = &""
	_a_Item_Icon.set_texture(null)
	
	removed.emit()

func get_item_key() -> StringName:
	return _a_item_key

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Item_Key"] = _a_item_key
	
	return data

func load_data(p_data: Dictionary) -> void:
	var item_key: StringName = p_data[&"Item_Key"]
	if item_key != &"":
		insert(item_key, true)
