extends FWDebugCommandEditCommandBase
class_name FWDebugCommandEditCommandMatch

@onready var _a_Menus: TabContainer = get_node("Window/Contents/Margin/VBox/VBox/Menus")
@onready var _a_Branches_Heading: RichTextLabel = get_node("Window/Contents/Margin/VBox/VBox/Branches/Heading")
@onready var _a_Branches: FWDebugValueEditEntryList = get_node("Window/Contents/Margin/VBox/VBox/Branches/Parts")

var _a_key: StringName = &"Choices"
var _a_menus: Dictionary[StringName, FWDebugCommandEditMenuBase] = {} # Match key to instance

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()
	
	for child: FWDebugCommandEditMenuBase in _a_Menus.get_children():
		var key: StringName = child.get_key()
		_a_menus[key] = child
	
	update_trans()

func update_trans() -> void:
	_a_Branches_Heading.set_text(tr(&"FW_DEBUG_CUTSCENES_BRANCHES"))

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	var instance: FWDebugCommandEditMenuBase = _a_menus[_a_key]
	instance.branches_values_changed.connect(_on_Menu_branches_values_changed)
	_branches_values_changed(instance)
	instance.show()
	
	_a_Menus.tab_changed.connect(_on_Menus_tab_changed)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data: Dictionary) -> void:
	for instance: FWDebugCommandEditMenuBase in _a_Menus.get_children():
		instance.load_data({})

func _open_load(p_data: Dictionary, _p_res_data: Dictionary) -> void:
	var menus_data: Dictionary = p_data[&"Menus"]
	for key: StringName in menus_data:
		var instance: FWDebugCommandEditMenuBase = _a_menus[key]
		instance.load_data(menus_data[key])
	
	_a_key = p_data[&"Key"]

func _update_branches(p_editable: bool, p_values: Array) -> void:
	var entries: Array[Node] = _a_Branches.get_entries()
	var size_: int = max(p_values.size(), entries.size())
	_a_Branches.set_show_duplicate(p_editable)
	_a_Branches.set_show_arrows(p_editable)
	_a_Branches.set_show_delete(p_editable)
	_a_Branches.set_show_add(p_editable)
	_a_Branches.set_type_editable(p_editable)
	_a_Branches.set_value_editable(p_editable)
	
	for i: int in size_:
		var instance: FWDebugEntryListEntry
		if entries.size() <= i:
			instance = _a_Branches.instantiate_entry_()
			_a_Branches.add_entry(instance)
		else:
			instance = entries[i]
		
		if p_values.size() > i:
			var value: Variant = p_values[i]
			instance.set_value.call_deferred(value)
		else:
			instance.queue_free()

func _branches_values_changed(p_instance: FWDebugCommandEditMenuBase) -> void:
	var branches_editable: bool = p_instance.is_branches_editable()
	var branches_values: Array = p_instance.get_branches_values()
	_update_branches(branches_editable, branches_values)

func _update_menu_data() -> void:
	var menu_instance: FWDebugCommandEditMenuBase = _a_menus[_a_key]
	var branches_values: Array = []
	var size_: int = _a_Branches.get_entry_count()
	branches_values.resize(size_)
	for i: int in size_:
		var instance: FWDebugEntryListEntry = _a_Branches.get_entry(i)
		var value: Variant = instance.get_value()
		branches_values[i] = value
	menu_instance.set_branches_values(branches_values)

func _get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Menus"] = {}
	for key: StringName in _a_menus:
		var instance: FWDebugCommandEditMenuBase = _a_menus[key]
		data[&"Menus"][key] = instance.get_save_data()
	data[&"Key"] = _a_key
	
	return data

func _on_Menus_tab_changed(p_idx: int) -> void:
	_update_menu_data()
	var instance: FWDebugCommandEditMenuBase = _a_menus[_a_key]
	instance.branches_values_changed.disconnect(_on_Menu_branches_values_changed)
	
	instance = _a_Menus.get_tab_control(p_idx)
	instance.branches_values_changed.connect(_on_Menu_branches_values_changed)
	_a_key = instance.get_key()
	_branches_values_changed(instance)

func _on_Menu_branches_values_changed() -> void:
	var instance: FWDebugCommandEditMenuBase = _a_menus[_a_key]
	_branches_values_changed(instance)

func _on_OK_pressed() -> void:
	_update_menu_data()
	super()
