extends HBoxContainer
class_name DebugGeneralTeleportScene

@onready var _a_Desc: Label = get_node("Desc")
@onready var _a_Select: Button = get_node("Select")
@onready var _a_Select_Teleport: DebugGeneralTeleportSceneSelect = get_node("Select_Teleport")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	Debug.closing.connect(_on_Debug_closing)

func update_trans() -> void:
	_a_Desc.set_text(tr(&"DEBUG_GENERAL_TELEPORT_SCENE"))
	_a_Select.set_text(tr(&"SELECT"))

func _on_Select_pressed() -> void:
	_a_Select_Teleport.open()

func _on_Debug_closing() -> void:
	_a_Select_Teleport.close()
