extends DebugCommandEditCommandPreviewObject
class_name DebugCommandEditCommandChangeEquipable

@onready var _a_Type: DebugValueSelectOptions = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Type")
@onready var _a_Equipable_Group: DebugCommandEditCommandChangeEquipableGroup = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Equipable_Group")
@onready var _a_Equipable: DebugValueSelectOptions = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Equipable")

var _a_equipable_group: StringName

func _ready() -> void:
	super()
	_a_Type.selected.connect(_on_Type_selected)
	_a_Equipable_Group.selected.connect(_on_Equipable_Group_selected)
	_a_Equipable.selected.connect(_on_Equipable_selected)
	
	_a_Type.update_options()
	_a_Equipable_Group.update_options()

func open(p_instance: DebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_update_object_equipables()
	_a_equipable_group = _a_Equipable_Group.get_selected_key()
	
	_a_Window.show()
	show()

func _open_init(p_res_data: Dictionary) -> void:
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Type.load_data_init()
	_a_Equipable_Group.load_data_init()
	_a_Equipable.load_data_init()

func _open_load(p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_data, p_res_data)
	_a_Object.load_data(p_data[&"Object"])
	_selected_object_changed()
	_a_Type.load_data(p_data[&"Type"])
	_a_Equipable_Group.load_data(p_data[&"Equipable_Group"])
	_a_Equipable.load_data(p_data[&"Equipable"])

func _update_equipables() -> void:
	var scenes: Dictionary = _a_object.comph().call_comp("Equipment", &"get_scenes")
	var equipable_group: StringName = _a_Equipable_Group.get_selected_key()
	var equipable_keys: Array = scenes[equipable_group].keys()
	_a_Equipable.set_options(equipable_keys)
	_a_Equipable.update_options()

func _update_object_equipables() -> void:
	var type: StringName = _a_Type.get_selected_key()
	var equipable_group: StringName = _a_Equipable_Group.get_selected_key()
	match type:
		&"Equip":
			var key: StringName = _a_Equipable.get_selected_key()
			if key != null:
				_set_object_revert_equipable(_a_object, equipable_group)
				_a_object.comph().call_comp("Equipment", &"equip", [equipable_group, key])
		&"Unequip":
			_set_object_revert_equipable(_a_object, equipable_group)
			_a_object.comph().call_comp("Equipment", &"unequip", [equipable_group])

func _selected_object_changed() -> void:
	super()
	if _a_object != null:
		var equipable_group: StringName = _a_Equipable_Group.get_selected_key()
		_revert_object_equipable(_a_object, equipable_group)
	
	_a_object = _a_Object.get_selected_value()
	_update_equipables()
	_update_object_equipables()

func _selected_type_changed() -> void:
	var type: StringName = _a_Type.get_selected_key()
	var is_equip: bool = type == &"Equip"
	_a_Equipable.set_visible(is_equip)
	
	_update_object_equipables()

func _selected_equipable_group_changed() -> void:
	_revert_object_equipable(_a_object, _a_equipable_group)
	
	_update_equipables()
	_update_object_equipables()
	_a_equipable_group = _a_Equipable_Group.get_selected_key()

func _selected_equipable_changed() -> void:
	_update_object_equipables()

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Type"] = _a_Type.get_save_data()
	data[&"Equipable_Group"] = _a_Equipable_Group.get_save_data()
	data[&"Equipable"] = _a_Equipable.get_save_data()
	
	return data

func _adjust_object_equipables(p_equipables: Dictionary) -> void:
	var type: StringName = _a_Type.get_selected_key()
	match type:
		&"Equip":
			var equipable: StringName = _a_Equipable.get_selected_key()
			p_equipables[_a_equipable_group] = equipable
		&"Unequip":
			p_equipables[_a_equipable_group] = &""

func _on_Type_selected() -> void:
	_selected_type_changed()

func _on_Equipable_Group_selected() -> void:
	_selected_equipable_group_changed()

func _on_Equipable_selected() -> void:
	_selected_equipable_changed()
