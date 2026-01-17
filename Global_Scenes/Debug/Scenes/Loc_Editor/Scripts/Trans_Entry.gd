extends VBoxContainer
class_name DebugLocEditorTransEntry

signal text_changed(p_text: String)

@onready var _a_Heading: RichTextLabel = get_node("Heading")
@onready var _a_Text: TextEdit = get_node("Text")

func _ready() -> void:
	_a_Text.text_changed.connect(_on_text_changed)

func set_heading(p_text: String) -> void:
	_a_Heading.set_text("[u]%s" % p_text)

func set_text(p_text: String) -> void:
	_a_Text.set_text(p_text)

func set_text_editable(p_editable: bool) -> void:
	_a_Text.set_editable(p_editable)

func _on_text_changed() -> void:
	var text: String = _a_Text.get_text()
	text_changed.emit(text)
