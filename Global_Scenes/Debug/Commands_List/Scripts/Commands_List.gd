extends CanvasLayer
class_name DebugCommandsList

signal command_selected(p_command: StringName)
signal closed()

@onready var _a_Window: WindowControlBase = get_node("Window")
@onready var _a_Movement_Heading: RichTextLabel = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/Heading")
@onready var _a_Camera_Heading: RichTextLabel = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Camera/Heading")
@onready var _a_Items_Heading: RichTextLabel = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Items/Heading")
@onready var _a_Timing_Heading: RichTextLabel = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Timing/Heading")
@onready var _a_Audio_Heading: RichTextLabel = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Audio/Heading")
@onready var _a_Misc_Heading: RichTextLabel = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/Heading")
@onready var _a_Flow_Control_Heading: RichTextLabel = get_node("Window/Contents/Margin/Tab/2/HSplit/Left/Flow_Control/Heading")

func _ready() -> void:
	_a_Window.closed.connect(_on_Window_closed)
	
	_connect_commands()
	_update_heading_trans()
	
	_a_Window.show()
	hide()

func update_trans() -> void:
	_update_heading_trans()

func _update_heading_trans() -> void:
	_a_Movement_Heading.set_text("[u]%s" % tr(&"DEBUG_CUTSCENES_COMMANDS_LIST_MOVEMENT"))
	_a_Camera_Heading.set_text("[u]%s" % tr(&"DEBUG_CUTSCENES_COMMANDS_LIST_CAMERA"))
	_a_Flow_Control_Heading.set_text("[u]%s" % tr(&"DEBUG_CUTSCENES_COMMANDS_LIST_FLOW_CONTROL"))
	_a_Items_Heading.set_text("[u]%s" % tr(&"DEBUG_CUTSCENES_COMMANDS_LIST_ITEMS"))
	_a_Timing_Heading.set_text("[u]%s" % tr(&"DEBUG_CUTSCENES_COMMANDS_LIST_TIMING"))
	_a_Audio_Heading.set_text("[u]%s" % tr(&"DEBUG_CUTSCENES_COMMANDS_LIST_AUDIO"))
	_a_Misc_Heading.set_text("[u]%s" % tr(&"DEBUG_CUTSCENES_COMMANDS_LIST_MISC"))

func open() -> void:
	_a_Window.show()
	show()

func close() -> void:
	_a_Window.hide()
	hide()
	closed.emit()

func _connect_commands() -> void:
	var instances: Array[Node] = get_tree().get_nodes_in_group(&"Cutscene_Command")
	for instance: DebugCommandsListEntry in instances:
		# Fix for Commands_List in Cutscenes/Stater
		if instance.get_owner() == self:
			instance.pressed.connect(_on_Command_pressed.bind(instance))

func _on_Window_closed() -> void:
	close()

func _on_Command_pressed(p_instance: DebugCommandsListEntry) -> void:
	var command: StringName = p_instance.get_command()
	command_selected.emit(command)
