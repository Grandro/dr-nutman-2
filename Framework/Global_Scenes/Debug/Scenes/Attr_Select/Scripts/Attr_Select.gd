extends CanvasLayer
class_name FWDebugAttrSelect

signal closed()
signal property_selected(p_property: StringName)
signal method_selected(p_method: StringName)

@onready var _a_Back: Button = get_node("Margin/Back")
@onready var _a_Properties: FWDebugEntryList = get_node("Margin/HBox/Properties/Entries")
@onready var _a_Methods: FWDebugEntryList = get_node("Margin/HBox/Methods/Entries")

func _ready() -> void:
	_a_Back.pressed.connect(_on_Back_pressed)
	_a_Properties.entry_select_pressed.connect(_on_Properties_entry_select_pressed)
	_a_Methods.entry_select_pressed.connect(_on_Methods_entry_select_pressed)
	Debug.closing.connect(_on_Debug_closing)

func open() -> void:
	show()

func close() -> void:
	hide()
	closed.emit()

func update_list(p_instance: Node) -> void:
	_a_Properties.clear_entries()
	_a_Methods.clear_entries()
	
	var properties: Array[Dictionary] = p_instance.get_property_list()
	for args: Dictionary in properties:
		var usage: PropertyUsageFlags = args[&"usage"]
		if !Debug.is_usage_for_editor(usage):
			continue
		
		var property: String = args[&"name"]
		var instance: FWDebugEntryListEntry = _a_Properties.instantiate_entry(property)
		instance.set_name_clip_text.call_deferred(true)
		instance.set_select_tooltip_text.call_deferred(property)
		_a_Properties.add_entry(instance)
	
	var methods: Array[Dictionary] = p_instance.get_method_list()
	for args: Dictionary in methods:
		var method: String = args[&"name"]
		var instance: FWDebugEntryListEntry = _a_Methods.instantiate_entry(method)
		instance.set_name_clip_text.call_deferred(true)
		instance.set_select_tooltip_text.call_deferred(method)
		_a_Methods.add_entry(instance)

func _on_Back_pressed() -> void:
	close()

func _on_Debug_closing() -> void:
	close()

func _on_Properties_entry_select_pressed(p_instance: FWDebugEntryListEntry) -> void:
	var property: StringName = p_instance.get_name_()
	property_selected.emit(property)
	close()

func _on_Methods_entry_select_pressed(p_instance: FWDebugEntryListEntry) -> void:
	var method: StringName = p_instance.get_name_()
	method_selected.emit(method)
	close()
