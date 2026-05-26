extends Control
class_name FWDebugCommandEditorWarnings

var _a_Warning_Entry_Scene: PackedScene = preload("uid://h4kuv52fetbs")

@onready var _a_Popup: Popup = get_node("Popup")
@onready var _a_Margin: MarginContainer = get_node("Popup/Margin")
@onready var _a_Entries: VBoxContainer = get_node("Popup/Margin/VBox/Entries")
@onready var _a_Fix: Button = get_node("Popup/Margin/VBox/Fix")

var _a_instance: FWDebugCommandEditorEntryCommand = null # Entry Instance

func _ready() -> void:
	_a_Popup.popup_hide.connect(_on_Popup_hide)
	_a_Fix.pressed.connect(_on_Fix_pressed)
	
	hide()

func open(p_pos: Vector2, p_instance: FWDebugCommandEditorEntryCommand) -> void:
	_a_instance = p_instance
	
	var warnings: Array[FWDebugCommandEditorEntryCommand.WarningArgsBase] = p_instance.get_warnings()
	for args: FWDebugCommandEditorEntryCommand.WarningArgsBase in warnings:
		var value_keys: Array = args.get_value_keys()
		var value: Variant = args.get_value()
		var text: String = "%s: %s" % [str(value_keys), str(value)]
		
		var instance: FWDebugCommandEditorWarningEntry = _a_Warning_Entry_Scene.instantiate()
		instance.set_text.call_deferred(text)
		_a_Entries.add_child(instance)
	
	var window_size: Vector2i = get_window().get_size()
	var min_size: Vector2 = _a_Margin.get_minimum_size()
	if p_pos.x + min_size.x > window_size.x:
		p_pos.x = window_size.x - min_size.x
	if p_pos.y + min_size.y > window_size.y:
		p_pos.y = window_size.y - min_size.y
	
	_a_Popup.popup(Rect2(p_pos, Vector2(400.0, min_size.y + 16.0)))
	show()

func _on_Popup_hide() -> void:
	for child: FWDebugCommandEditorWarningEntry in _a_Entries.get_children():
		child.queue_free()
	hide()

func _on_Fix_pressed() -> void:
	var fix_warnings: FWDebugFixWarnings = Debug.get_fix_warnings()
	fix_warnings.open(_a_instance)
	
	_a_Popup.hide()
	hide()
