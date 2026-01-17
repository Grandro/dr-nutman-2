extends Control
class_name MiniGameColorSelectionResult

signal ok_pressed()
signal play_again_pressed()

@onready var _a_Heading: Label = get_node("HBox/VBox/Heading")
@onready var _a_Bust_Text: RichTextLabel = get_node("HBox/VBox/HBox_1/Bust/Text")
@onready var _a_Color: ColorRect = get_node("HBox/VBox/HBox_1/Color")
@onready var _a_OK: Button = get_node("HBox/VBox/HBox_2/OK")
@onready var _a_Play_Again: Button = get_node("HBox/VBox/HBox_2/Play_Again")
@onready var _a_Prev_Colors: MiniGameColorSelectionPrevColors = get_node("HBox/Prev_Colors")

func _ready() -> void:
	_a_OK.pressed.connect(_on_OK_pressed)
	_a_Play_Again.pressed.connect(_on_Play_Again_pressed)
	_a_Prev_Colors.color_selected.connect(_on_Prev_Colors_color_selected)
	
	_a_Bust_Text.set_text(tr(&"MINIGAMES_COLOR_SELECTION_ISTHATFAVCOLOR"))
	
	_a_Prev_Colors.hide()

func update_trans() -> void:
	_a_Heading.set_text(tr(&"MINIGAMES_COLOR_SELECTION_RESULT"))
	_a_Bust_Text.set_text(tr(&"MINIGAMES_COLOR_SELECTION_ISTHATFAVCOLOR"))

func open(p_color: Color) -> void:
	_a_Color.set_color(p_color)
	_a_Prev_Colors.open(p_color)
	
	show()

func _on_OK_pressed() -> void:
	var color: Color = _a_Color.get_color()
	Global_Data.set_fav_color(color)
	
	_a_Prev_Colors.close()
	hide()
	
	ok_pressed.emit()

func _on_Play_Again_pressed() -> void:
	_a_Prev_Colors.close()
	hide()
	
	play_again_pressed.emit()

func _on_Prev_Colors_color_selected(p_color: Color) -> void:
	_a_Color.set_color(p_color)
