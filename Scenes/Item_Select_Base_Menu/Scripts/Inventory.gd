extends ItemSelectBase
class_name ItemSelectInventory

func _instantiate_items() -> void:
	var inventory: Dictionary = Global.get_inventory()
	for type: StringName in _e_tabs:
		var tab_instance: ItemSelectTabEntry = _a_tab_instances[type]
		var groups: Array[StringName] = tab_instance.get_groups_()
		for group: StringName in groups:
			for key: StringName in inventory[type][group]:
				if _get_instantiate_item(key):
					instantiate_item(key)
	
	_sort_items.call_deferred()

func instantiate_item(p_key: StringName) -> void:
	var item_args: ItemData = Databases.get_data_entry(&"Items", p_key)
	var item_type: StringName = item_args.get_type()
	var item_group: StringName = item_args.get_group()
	var global_si: Global = Global.get_singleton(self, "Global")
	var inventory: Dictionary = global_si.get_inventory()
	var inventory_args: Dictionary = inventory[item_type][item_group][p_key]
	var tab_instance: ItemSelectTabEntry = _a_tab_instances[item_type]
	
	var item_name: String = item_args.get_name_()
	var item_texture: Texture2D = item_args.get_texture()
	var amount: int = inventory_args[&"Amount"]
	var instance: ItemEntryInventory = _a_Item_Entry_Scene.instantiate()
	instance.pressed.connect(_on_Item_pressed.bind(instance))
	instance.set_texture.call_deferred(item_texture)
	instance.set_amount.call_deferred(amount)
	instance.set_key(p_key)
	instance.set_name_(item_name)
	
	_a_items[p_key] = instance
	tab_instance.add_item(instance, item_group)

func set_info_options_disabled(p_disabled: bool) -> void:
	_a_Info.set_options_disabled(p_disabled)
