extends PanelContainer
class_name FWDebugValueEditEdit

signal type_changed(p_type: Variant.Type)
signal remove_item_pressed()

var _a_Type_Entry_Scene: PackedScene = preload("uid://qm76d6rgsaby")
var _a_Type_HSep_Scene: PackedScene = preload("uid://c77u5wi0oy17g")

@onready var _a_Select: TextureButton = get_node("Select")
@onready var _a_Types: Popup = get_node("Select/Types")
@onready var _a_Types_VBox: VBoxContainer = get_node("Select/Types/VBox")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)

func update_types(p_type_keys: Dictionary[Variant.Type, String], p_editable: bool, p_removable: bool) -> void:
	for child: Control in _a_Types_VBox.get_children():
		child.queue_free()
	
	if p_editable:
		for type: Variant.Type in p_type_keys:
			var instance: Button = _a_Type_Entry_Scene.instantiate()
			instance.pressed.connect(_on_Type_pressed.bind(type))
			instance.set_text(p_type_keys[type])
			_a_Types_VBox.add_child(instance)
	
	if p_removable:
		if p_editable:
			var sep_instance: HSeparator = _a_Type_HSep_Scene.instantiate()
			_a_Types_VBox.add_child(sep_instance)
		
		var instance: Button = _a_Type_Entry_Scene.instantiate()
		instance.pressed.connect(_on_Remove_Item_pressed)
		instance.set_text(tr(&"FW_DEBUG_VALUE_EDIT_REMOVE_ITEM"))
		_a_Types_VBox.add_child(instance)

func _on_Select_pressed() -> void:
	_a_Types.show()
	var pos: Vector2 = get_global_position()
	pos.x -= _a_Types.size.x
	var size_: Vector2 = _a_Types_VBox.get_size()
	_a_Types.popup(Rect2(pos, size_))
	_a_Types.set_size(size_)

func _on_Type_pressed(p_type: Variant.Type) -> void:
	_a_Types.hide()
	type_changed.emit(p_type)

func _on_Remove_Item_pressed() -> void:
	_a_Types.hide()
	remove_item_pressed.emit()
