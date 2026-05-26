extends VBoxContainer
class_name FWDebugCommandEditCommandMatchChoicesChoiceEntry

@onready var _a_Heading: RichTextLabel = get_node("Heading")
@onready var _a_Text: Label = get_node("Text/Value")
@onready var _a_Value: Label = get_node("Value/Value")

func set_heading(p_text: String) -> void:
	_a_Heading.set_text("[u]%s" % p_text)

func set_text(p_text: String) -> void:
	_a_Text.set_text(p_text)

func set_value(p_text: String) -> void:
	_a_Value.set_text(p_text)
