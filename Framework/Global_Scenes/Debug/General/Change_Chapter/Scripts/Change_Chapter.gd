extends HBoxContainer
class_name FWDebugGeneralChangeChapter

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Select_Chapter: FWDebugGeneralChangeChapterSelect = get_node("Select_Chapter")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	Debug.closing.connect(_on_Debug_closing)

func _on_Select_pressed() -> void:
	_a_Select_Chapter.open()

func _on_Debug_closing() -> void:
	_a_Select_Chapter.close()
