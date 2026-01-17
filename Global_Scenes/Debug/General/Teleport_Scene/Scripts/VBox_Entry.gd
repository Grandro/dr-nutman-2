extends VBoxContainer
class_name DebugGeneralTeleportSceneVBoxEntry

@onready var _a_Heading: Label = get_node("Heading")

func set_heading_text(p_text: String) -> void:
	_a_Heading.set_text(p_text)
