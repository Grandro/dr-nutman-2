extends ScrollContainer
class_name ItemSelectTabEntry

signal group_changed(p_group: StringName)
signal group_mouse_entered()
signal group_mouse_exited()

@export var _e_type: StringName = &""
@export var _e_groups: Array[StringName] = []
@export var _e_has_icons: bool = false

var _a_Group_Entry_Scene: PackedScene = preload("res://Scenes/Item_Select_Base_Menu/Tab_Entry/Scenes/Group_Entry.tscn")

@onready var _a_Icons: MarginContainer = get_node("VBox/Icons")
@onready var _a_Icons_Toggler: KeyEntryToggler = get_node("VBox/Icons/Toggler")
@onready var _a_HSep: HSeparator = get_node("VBox/HSep")
@onready var _a_Groups: MarginContainer = get_node("VBox/Groups")

var _a_groups: Dictionary[StringName, HFlowContainer] = {} # Match key to instance
var _a_group_instance: HFlowContainer # Current group instance
var _a_group: StringName # Current group

func _ready() -> void:
	_a_Icons_Toggler.toggled.connect(_on_Icons_Toggler_toggled)
	
	for i: int in _e_groups.size():
		var group: StringName = _e_groups[i]
		var group_instance: HFlowContainer = _a_Group_Entry_Scene.instantiate()
		group_instance.mouse_entered.connect(_on_Group_Entry_mouse_entered)
		group_instance.mouse_exited.connect(_on_Group_Entry_mouse_exited)
		
		if i == 0:
			_a_group_instance = group_instance
			_a_group = group
		else:
			group_instance.hide()
		_a_groups[group] = group_instance
		_a_Groups.add_child(group_instance)
		
		if _e_has_icons:
			var item_type_icon_path: String = Global.get_item_type_icon_path()
			var texture: Texture2D = load(item_type_icon_path % [_e_type, group])
			var instance: EntryTogglerKeyEntry = _a_Icons_Toggler.instantiate_entry_("", texture, group)
			_a_Icons_Toggler.add_entry(instance)
	
	_a_Icons.set_visible(_e_has_icons)
	_a_HSep.set_visible(_e_has_icons)

func add_item(p_instance: ItemEntryInventory, p_group: StringName) -> void:
	var group: HFlowContainer = _a_groups[p_group]
	group.add_child(p_instance)

func clear_items() -> void:
	for group: HFlowContainer in _a_groups.values():
		for child: ItemEntryInventory in group.get_children():
			child.queue_free()

func move_item_curr(p_instance: ItemEntryInventory, p_idx: int) -> void:
	_a_group_instance.move_child(p_instance, p_idx)

func get_type() -> StringName:
	return _e_type

func get_groups_() -> Array[StringName]:
	return _e_groups

func get_first_item_curr() -> ItemEntryInventory:
	var first: ItemEntryInventory = null
	for child: ItemEntryInventory in _a_group_instance.get_children():
		if child.get_amount() > 0:
			first = child
			break
	
	return first

func get_curr_group_instance() -> HFlowContainer:
	return _a_group_instance

func get_curr_group() -> StringName:
	return _a_group

func _on_Icons_Toggler_toggled(p_instance: EntryTogglerKeyEntry) -> void:
	_a_group_instance.hide()
	
	var group: StringName = p_instance.get_key()
	_a_group_instance = _a_groups[group]
	_a_group_instance.show()
	_a_group = group
	
	group_changed.emit(group)

func _on_Group_Entry_mouse_entered() -> void:
	group_mouse_entered.emit()

func _on_Group_Entry_mouse_exited() -> void:
	group_mouse_exited.emit()
