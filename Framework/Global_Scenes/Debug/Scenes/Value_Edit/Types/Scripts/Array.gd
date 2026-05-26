extends VBoxContainer
class_name FWDebugValueEditTypeArray

signal value_changed(p_value: Array)

var _a_Value_Edit_Scene: PackedScene = load("uid://bc12fh7xhsyy6")

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Value: VBoxContainer = get_node("Value")
@onready var _a_Size: SpinBox = get_node("Value/Size/Margin/HBox/Value")
@onready var _a_Entries: VBoxContainer = get_node("Value/Entries")

var _a_data: FWValueEditData
var _a_color_idx: int

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Size.value_changed.connect(_on_Size_value_changed)
	
	_close_value()

func expand(p_depth: int) -> void:
	set_expanded(true)
	
	if p_depth != -1:
		p_depth -= 1
	if p_depth == 0:
		return
	
	for child: FWDebugValueEdit in _a_Entries.get_children():
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
	var entries_count: int = _a_Entries.get_child_count()
	var value: Array = _a_data.get_value()
	var value_size: int = value.size()
	var diff: int = value_size - entries_count
	if diff > 0:
		for i: int in range(entries_count, value_size):
			var instance: FWDebugValueEdit = _instantiate_value_edit(i)
			if instance.get_type() != typeof(value[i]):
				value[i] = instance.get_value()
			_a_Entries.add_child(instance)
	else:
		for i: int in range(entries_count - 1, value_size - 1, -1):
			var child: FWDebugValueEdit = _a_Entries.get_child(i)
			_delete_value_entry(child)
	
	for i: int in value_size:
		var child: FWDebugValueEdit = _a_Entries.get_child(i)
		child.set_value(value[i])
	
	value_changed.emit(value)

func _clear_value_entries() -> void:
	for child: FWDebugValueEdit in _a_Entries.get_children():
		_delete_value_entry(child)

func _delete_value_entry(p_instance: FWDebugValueEdit) -> void:
	p_instance.tree_exiting.disconnect(_on_Value_Edit_tree_exiting)
	p_instance.value_changed.disconnect(_on_Value_Edit_value_changed)
	p_instance.delete.call_deferred()

func _update_select_text() -> void:
	var value: Array = _a_data.get_value()
	var size_: int = value.size()
	var text: String = "Array (size %s)" % size_
	_a_Select.set_text(text)
	_a_Size.set_value_no_signal(size_)

func _instantiate_value_edit(p_idx: int) -> FWDebugValueEdit:
	var instance: FWDebugValueEdit = _a_Value_Edit_Scene.instantiate()
	var child_data: FWValueEditData = _a_data.get_arr_child_data_idx(p_idx)
	instance.value_changed.connect(_on_Value_Edit_value_changed.bind(instance))
	instance.tree_exiting.connect(_on_Value_Edit_tree_exiting.bind(instance))
	instance.set_init(false)
	instance.set_data(child_data)
	instance.set_color_idx(_a_color_idx)
	instance.set_text.call_deferred(str(p_idx))
	instance.show_text.call_deferred()
	
	return instance

func set_default_value() -> void:
	set_value([])

func set_value(p_value: Array) -> void:
	_a_data.set_value(p_value)
	_update_select_text()
	if _a_Value.is_visible():
		_update_value_entries()

func get_value() -> Array:
	return _a_data.get_value()

func set_value_editable(p_value_editable: bool) -> void:
	_a_data.set_value_editable(p_value_editable)
	_set_value_editable(p_value_editable)

func _set_value_editable(p_value_editable: bool) -> void:
	_a_Size.set_editable(p_value_editable)

func set_expanded(p_expanded: bool) -> void:
	_a_data.set_expanded(p_expanded)
	if p_expanded:
		_open_value()
	else:
		_close_value()

func set_data(p_data: FWValueEditData) -> void:
	_a_data = p_data
	_set_data(p_data)

func _set_data(p_data: FWValueEditData) -> void:
	var child_data: Array[FWValueEditData] = p_data.get_arr_child_data()
	if child_data.is_empty():
		return
	
	var value: Array = _a_data.get_value()
	value.resize(child_data.size())
	_update_select_text()
	if _a_Value.is_visible():
		_update_value_entries()

func set_color_idx(p_color_idx: int) -> void:
	_a_color_idx = p_color_idx

func _on_Select_pressed() -> void:
	var expanded: bool = !_a_Value.is_visible()
	set_expanded(expanded)

func _on_Size_value_changed(p_value: int) -> void:
	var value: Array = _a_data.get_value()
	value.resize(p_value)
	_update_select_text()
	if _a_Value.is_visible():
		_update_value_entries()

func _on_Value_Edit_value_changed(p_value: Variant, p_instance: FWDebugValueEdit) -> void:
	var idx: int = p_instance.get_index()
	var value: Array = _a_data.get_value()
	value[idx] = p_value
	
	value_changed.emit(value)

func _on_Value_Edit_tree_exiting(p_instance: FWDebugValueEdit) -> void:
	var idx: int = p_instance.get_index()
	p_instance.tree_exited.connect(_on_Value_Edit_tree_exited.bind(idx))

func _on_Value_Edit_tree_exited(p_idx: int) -> void:
	var value: Array = _a_data.get_value()
	value.pop_at(p_idx)
	_update_select_text()
	
	for i: int in _a_Entries.get_child_count():
		var child: FWDebugValueEdit = _a_Entries.get_child(i)
		child.set_text(str(i))
	
	value_changed.emit(value)
