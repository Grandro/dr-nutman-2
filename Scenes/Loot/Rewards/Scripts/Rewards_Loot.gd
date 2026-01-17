extends HFlowContainer
class_name LootRewardsLoot

signal completed()

@export var _e_include_coins: bool = false
@export var _e_item_entry_scene: PackedScene = preload("res://Scenes/Item_Entry/Item_Entry_Loot.tscn")

var _a_Coin_Image: Texture2D = preload("res://Global_Resources/Sprites/Coin/48_Single.png")

func open(p_loot: Dictionary[StringName, int]) -> void:
	_instantiate_items(p_loot)
	
	completed.emit()

func close() -> void:
	for child: ItemEntryLoot in get_children():
		child.queue_free()

func _instantiate_items(p_loot: Dictionary[StringName, int]) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var items_data: Dictionary = Databases.get_data(&"Items")
	for item_key: StringName in p_loot:
		if !_get_include_item(item_key):
			continue
		
		var amount: int = p_loot[item_key]
		if amount == 0:
			continue
		
		var instance: ItemEntryLoot = _e_item_entry_scene.instantiate()
		if item_key == &"$Coins":
			global_si.change_coins_amount(amount)
			instance.set_name_.call_deferred(tr(&"COINS_NAME"))
			instance.set_texture.call_deferred(_a_Coin_Image)
		else:
			global_si.change_item_amount(item_key, amount)
			var item_args: ItemData = items_data[item_key]
			var item_name: String = item_args.get_name_()
			var item_texture: Texture2D = item_args.get_texture()
			instance.set_name_.call_deferred(item_name)
			instance.set_texture.call_deferred(item_texture)
		instance.set_amount.call_deferred(amount)
		
		add_child(instance)

func _get_include_item(p_key: StringName) -> bool:
	var include: bool = true
	if p_key.begins_with("$"):
		if p_key != &"$Coins" || !_e_include_coins:
			include = false
	
	return include
