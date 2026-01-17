extends DebugEntryList
class_name DebugExpressionEntryList

func instantiate_entry_(p_data: Dictionary, p_self_key: StringName = &"", p_name: String = "") -> DebugEntryListExpressionEntry:
	var instance: DebugEntryListExpressionEntry = instantiate_entry(p_name)
	instance.update_expression_self.call_deferred(p_self_key)
	instance.update_expression_instances.call_deferred()
	instance.load_expression_data.call_deferred(p_data)
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> DebugEntryListExpressionEntry:
	var data: Dictionary = p_data[&"Expression"]
	var self_key: StringName = p_data[&"Expression_Self_Key"]
	var name_: String = p_data[&"Name"]
	var instance = instantiate_entry_(data, self_key, name_)
	
	return instance

func _on_Add_pressed() -> void:
	var instance = instantiate_entry_({})
	add_entry(instance)
