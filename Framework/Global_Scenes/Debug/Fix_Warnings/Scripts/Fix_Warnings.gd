extends CanvasLayer
class_name FWDebugFixWarnings

const _a_ENTRY_PATH: String = "res://Framework/Global_Scenes/Debug/Fix_Warnings/Entries/Fix_Warning_%s.tscn"

@onready var _a_Window: FWWindowControlBase = get_node("Control/Window")
@onready var _a_Entries: VBoxContainer = get_node("Control/Window/Contents/Margin/VBox/Scroll/Entries")
@onready var _a_OK: Button = get_node("Control/Window/Contents/Margin/VBox/HBox/OK")
@onready var _a_Cancel: Button = get_node("Control/Window/Contents/Margin/VBox/HBox/Cancel")

var _a_instance: FWDebugCommandEditorEntryCommand # Entry instance

func _ready() -> void:
	_a_Window.hidden.connect(_on_Window_hidden)
	_a_OK.pressed.connect(_on_OK_pressed)
	_a_Cancel.pressed.connect(_on_Cancel_pressed)
	
	_a_Window.set_title(tr(&"FW_DEBUG_FIX_WARNINGS"))
	hide()

func open(p_instance: FWDebugCommandEditorEntryCommand) -> void:
	_a_instance = p_instance
	
	var data: Dictionary = p_instance.get_data()
	var warnings: Array[FWDebugCommandEditorEntryCommand.WarningArgsBase] = p_instance.get_warnings()
	for args: FWDebugCommandEditorEntryCommand.WarningArgsBase in warnings:
		var type: StringName = args.get_type()
		var scene: PackedScene = load(_a_ENTRY_PATH % type)
		var instance: FWDebugFixWarningsEntryBase = scene.instantiate()
		instance.set_data(data)
		instance.set_warning(args)
		
		_a_Entries.add_child(instance)
	
	_a_Window.show()
	show()

func close() -> void:
	for child: FWDebugFixWarningsEntryBase in _a_Entries.get_children():
		child.queue_free()
	hide()

func _on_Window_hidden() -> void:
	close()

func _on_OK_pressed() -> void:
	for child: FWDebugFixWarningsEntryBase in _a_Entries.get_children():
		child.apply_changes()
	
	_a_instance.update_display()
	_a_instance.update_warnings()
	
	close()

func _on_Cancel_pressed() -> void:
	close()
