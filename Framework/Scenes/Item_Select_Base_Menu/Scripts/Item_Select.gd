extends FWItemSelectBase
class_name FWItemSelect

signal select_pressed(p_key: StringName, p_stack: int, p_texture: Texture2D)

func _ready() -> void:
	super()
	_a_Info.select_pressed.connect(_on_Info_select_pressed)

func open(p_key: StringName = &"") -> void:
	await super()
	if p_key != &"":
		_grab_item_focus(p_key)

func _instantiate_items() -> void:
	var items_data: Dictionary = Databases.get_data(&"Items")
	for key: StringName in items_data:
		if _get_instantiate_item(key):
			instantiate_item(key)
	
	_sort_items.call_deferred()

func instantiate_item(p_key: StringName) -> void:
	var item_args: FWItemData = Databases.get_data_entry(&"Items", p_key)
	var item_type: StringName = item_args.get_type()
	var item_group: StringName = item_args.get_group()
	var tab_instance: FWItemSelectTabEntry = _a_tab_instances[item_type]
	var item_name: String = item_args.get_name_()
	var item_texture: Texture2D = item_args.get_texture()
	var stack: int = item_args.get_stack_()
	var instance: FWItemEntryInventory = _a_Item_Entry_Scene.instantiate()
	instance.pressed.connect(_on_Item_pressed.bind(instance))
	instance.set_key(p_key)
	instance.set_name_(item_name)
	instance.set_type(item_type)
	#instance.set_group(item_group)
	instance.set_texture.call_deferred(item_texture)
	instance.set_amount.call_deferred(stack)
	
	_a_items[p_key] = instance
	tab_instance.add_item(instance, item_group)

func _grab_item_focus(p_key: StringName) -> void:
	var item_instance: FWItemEntryInventory = _a_items[p_key]
	var type: StringName = item_instance.get_type()
	var tab_instance: FWItemSelectTabEntry = _a_tab_instances[type]
	var idx: int = tab_instance.get_index()
	_a_Items.set_current_tab(idx)
	
	item_instance.grab_select_focus()
	_selected_item_changed(item_instance)

func get_first_data() -> Dictionary:
	var data: Dictionary = {}
	var items_data: Dictionary = Databases.get_data(&"Items")
	var item_keys: Array[StringName] = items_data.keys()
	if item_keys.size() > 0:
		var key: StringName = item_keys[0]
		data[&"Key"] = key
		data[&"Stack"] = items_data[key].get_stack()
	
	return data

func _on_Info_select_pressed() -> void:
	var key: StringName = _a_instance.get_key()
	var stack: int = _a_instance.get_amount()
	var texture: Texture2D = _a_instance.get_texture()
	select_pressed.emit(key, stack, texture)
