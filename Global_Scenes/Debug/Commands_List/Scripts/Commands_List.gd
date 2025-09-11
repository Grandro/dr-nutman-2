extends CanvasLayer

signal command_selected(p_command)
signal closed()

@onready var _a_Window = get_node("Window")
@onready var _a_Movement_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/Heading")
@onready var _a_Camera_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Camera/Heading")
@onready var _a_Items_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Items/Heading")
@onready var _a_Timing_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Timing/Heading")
@onready var _a_Audio_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Audio/Heading")
@onready var _a_Misc_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/Heading")
@onready var _a_Flow_Control_Heading = get_node("Window/Contents/Margin/Tab/2/HSplit/Left/Flow_Control/Heading")

func _ready():
	_a_Window.closed.connect(_on_Window_closed)
	
	_connect_commands()
	_update_heading_trans()
	
	_a_Window.show()
	hide()

func update_trans():
	_update_heading_trans()

func _update_heading_trans():
	_a_Movement_Heading.set_text("[u]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_MOVEMENT"))
	_a_Camera_Heading.set_text("[u]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_CAMERA"))
	_a_Flow_Control_Heading.set_text("[u]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_FLOW_CONTROL"))
	_a_Items_Heading.set_text("[u]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_ITEMS"))
	_a_Timing_Heading.set_text("[u]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_TIMING"))
	_a_Audio_Heading.set_text("[u]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_AUDIO"))
	_a_Misc_Heading.set_text("[u]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_MISC"))

func open():
	_a_Window.show()
	show()

func close():
	_a_Window.hide()
	hide()
	closed.emit()

func _connect_commands():
	var instances = get_tree().get_nodes_in_group("Cutscene_Command")
	for instance in instances:
		# Fix for Commands_List in Cutscenes/Stater
		if instance.get_owner() == self:
			instance.pressed.connect(_on_Command_pressed.bind(instance))

func _on_Window_closed():
	close()

func _on_Command_pressed(p_instance):
	var command = p_instance.get_command()
	command_selected.emit(command)
