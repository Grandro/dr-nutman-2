extends ItemSelectBaseMenu
class_name DebugItemSelectMenu

signal select_pressed(p_key: StringName, p_stack: int, p_texture: Texture2D)

@onready var _a_Item_Select: ItemSelect = get_node("Item_Select")

func _ready() -> void:
	super()
	_a_Item_Select.select_pressed.connect(_on_Item_Select_select_pressed)

func open(p_key: StringName) -> void:
	_a_Item_Select.open(p_key)
	show()

func close() -> void:
	_a_Item_Select.close()
	super()

func _on_Item_Select_select_pressed(p_key: StringName, p_stack: int, p_texture: Texture2D) -> void:
	select_pressed.emit(p_key, p_stack, p_texture)
	close()
