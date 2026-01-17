extends DebugCommandEditorEntryCommand
class_name DebugCommandEditorEntryChangeItemAmount

# Breakable: [&"Item"][&"Value"], [&"Amount"][&"Value"]
func _update_warnings_add() -> void:
	var items_data: Dictionary = Databases.get_data(&"Items")
	var item_key: StringName = _a_data[&"Item"][&"Value"]
	if !items_data.has(item_key):
		var value_keys: Array = [&"Item", &"Value"]
		var args: WarningArgsStringName = WarningArgsStringName.new(item_key, value_keys)
		_a_warnings.push_back(args)
	else:
		var amount: int = _a_data[&"Amount"][&"Value"]
		var item_args: ItemData = items_data[item_key]
		var item_stack: int = item_args.get_stack_()
		if amount > item_stack:
			var value_keys: Array = [&"Amount", &"Value"]
			var args: WarningArgsInt = WarningArgsInt.new(amount, value_keys, 0, item_stack)
			_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var type: StringName = _a_data[&"Type"][&"Value"]
	var item_text: String = _get_display_text(_a_data[&"Item"])
	var amount_text: String = _get_display_text(_a_data[&"Amount"])
	
	var text: String = item_text
	match type:
		&"Gain": text += " +"
		&"Lose": text += " -"
	text += str(amount_text)
	_a_Main.set_base_args(text)
