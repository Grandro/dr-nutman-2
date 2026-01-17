extends VBoxContainer
class_name DebugValueEditTypeDictionary

signal value_changed(p_value: Dictionary)

var _a_Value_Edit_Scene: PackedScene = load("res://Global_Scenes/Debug/Scenes/Value_Edit/Value_Edit.tscn")

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Value: VBoxContainer = get_node("Value")
@onready var _a_Entries: VBoxContainer = get_node("Value/Entries")
@onready var _a_New_Key: LineEdit = get_node("Value/New_Key/Margin/HBox/Value")
@onready var _a_New_Value_HBox: HBoxContainer = get_node("Value/New_Value/Margin/HBox")
@onready var _a_Add: Button = get_node("Value/Add")

var _a_data: ValueEditData
var _a_color_idx: int
var _a_value_edit: DebugValueEdit

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Add.pressed.connect(_on_Add_pressed)
	
	_a_value_edit = _a_Value_Edit_Scene.instantiate()
	_a_New_Value_HBox.add_child(_a_value_edit)
	
	_close_value()

func expand(p_depth: int) -> void:
	set_expanded(true)
	
	if p_depth != -1:
		p_depth -= 1
	if p_depth == 0:
		return
	
	for child: DebugValueEdit in _a_Entries.get_children():
		child.expand(p_depth)

func delete() -> void:
	_clear_value_entries()
	queue_free()

func to_color(_p_color: Color) -> void:
	pass

func _open_value() -> void:
	_update_value_entries()
	_a_Value.show()

func _close_value() -> void:
	_clear_value_entries()
	_a_Value.hide()

func _update_value_entries() -> void:
	_clear_value_entries()
	
	var value: Dictionary = _a_data.get_value()
	for key: Variant in value:
		var instance: DebugValueEdit = _instantiate_value_edit(key)
		_a_Entries.add_child(instance)
		instance.set_value(value[key])

func _clear_value_entries() -> void:
	for child: DebugValueEdit in _a_Entries.get_children():
		child.tree_exited.disconnect(_on_Value_Edit_tree_exited)
		child.value_changed.disconnect(_on_Value_Edit_value_changed)
		child.delete.call_deferred()

func _update_select_text() -> void:
	var value: Dictionary = _a_data.get_value()
	var size_: int = value.size()
	var text: String = "Dictionary (size %s)" % size_
	_a_Select.set_text(text)

func _instantiate_value_edit(p_key: Variant) -> DebugValueEdit:
	var instance: DebugValueEdit = _a_Value_Edit_Scene.instantiate()
	var child_data: ValueEditData = _a_data.get_dic_child_data_key(p_key)
	instance.value_changed.connect(_on_Value_Edit_value_changed.bind(p_key))
	instance.tree_exited.connect(_on_Value_Edit_tree_exited.bind(p_key))
	instance.set_init(false)
	instance.set_data(child_data)
	instance.set_color_idx(_a_color_idx)
	instance.set_text.call_deferred(p_key)
	instance.show_text.call_deferred()
	
	return instance

func set_default_value() -> void:
	set_value({})

func set_value(p_value: Dictionary) -> void:
	_a_data.set_value(p_value)
	_update_select_text()
	if _a_Value.is_visible():
		_update_value_entries()

func get_value() -> Dictionary:
	return _a_data.get_value()

func set_value_editable(p_value_editable: bool) -> void:
	_a_data.set_value_editable(p_value_editable)
	_set_value_editable(p_value_editable)

func _set_value_editable(p_value_editable: bool) -> void:
	_a_New_Key.set_editable(p_value_editable)
	_a_value_edit.set_value_editable(p_value_editable)
	_a_Add.set_disabled(!p_value_editable)

func set_expanded(p_expanded: bool) -> void:
	_a_data.set_expanded(p_expanded)
	if p_expanded:
		_open_value()
	else:
		_close_value()

func set_data(p_data: ValueEditData) -> void:
	_a_data = p_data
	_set_data(p_data)

func _set_data(p_data: ValueEditData) -> void:
	var child_data: Dictionary[Variant, ValueEditData] = p_data.get_dic_child_data()
	if child_data.is_empty():
		return
	
	for key: Variant in child_data:
		_a_data[key] = child_data[key]
	_update_select_text()
	if _a_Value.is_visible():
		_update_value_entries()

func set_color_idx(p_color_idx: int) -> void:
	_a_color_idx = p_color_idx

func _on_Select_pressed() -> void:
	var expanded: bool = !_a_Value.is_visible()
	set_expanded(expanded)

func _on_Add_pressed() -> void:
	var value: Dictionary = _a_data.get_value()
	var key: String = _a_New_Key.get_text()
	_a_New_Key.set_text("")
	if key.is_empty() || value.has(key):
		return
	
	var new_value: Variant = _a_value_edit.get_value()
	value[key] = new_value
	_a_value_edit.set_instance_default_value()
	_update_select_text()
	if _a_Value.is_visible():
		_update_value_entries()

func _on_Value_Edit_value_changed(p_value: Variant, p_key: Variant) -> void:
	var value: Dictionary = _a_data.get_value()
	value[p_key] = p_value
	value_changed.emit(value)

func _on_Value_Edit_tree_exited(p_key: Variant) -> void:
	var value: Dictionary = _a_data.get_value()
	value.erase(p_key)
	_update_select_text()
	
	value_changed.emit(value)
