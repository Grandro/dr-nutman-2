extends MarginContainer
class_name FWCompSpeechBubbleUI

signal choice_selected(p_value: Variant)

@onready var _a_Text: RichTextLabel = get_node("VBox/Text_Box/Margin/Text")
@onready var _a_Proceed_Dot: TextureRect = get_node("VBox/Text_Box/Proceed_Dot")
@onready var _a_Choices_Box: FWCompSpeechBubbleChoicesBox = get_node("VBox/Choices_Box")
@onready var _a_Arrow: TextureRect = get_node("Control/Arrow")

func _ready() -> void:
	_a_Choices_Box.choice_selected.connect(_on_Choices_Box_choice_selected)
	
	_a_Proceed_Dot.hide()
	_a_Choices_Box.hide()
	_a_Arrow.hide()
	hide()

func open() -> void:
	_a_Text.set_fit_content.call_deferred(true)
	
	show()
	_a_Arrow.show()

func open_choices_box(p_args: Dictionary) -> void:
	_a_Choices_Box.open(p_args)

func reset(p_fade_out: bool) -> void:
	_a_Text.set_text("")
	_a_Text.set_visible_characters(0)
	if p_fade_out:
		_a_Arrow.set_flip_v(false)
		
		_a_Proceed_Dot.hide()
		_a_Choices_Box.hide()
		_a_Arrow.hide()
		hide()

func show_proceed_dot() -> void:
	_a_Proceed_Dot.show()

func insert_text(p_pos: int, p_text: String) -> void:
	_a_Text.text.insert(p_pos, p_text)

func set_text(p_text: String) -> void:
	_a_Text.set_text("[center]%s" % p_text)

func set_text_visible_characters(p_amount: int) -> void:
	_a_Text.set_visible_characters(p_amount)

func get_text_visible_characters() -> int:
	return _a_Text.get_visible_characters()

func get_text_length() -> int:
	return _a_Text.get_total_character_count()

func set_arrow_global_pos(p_pos: Vector2) -> void:
	_a_Arrow.set_global_position(p_pos)

func set_arrow_flip_v(p_flip_v: bool) -> void:
	_a_Arrow.set_flip_v(p_flip_v)

func get_arrow_size() -> Vector2:
	return _a_Arrow.get_size()

func _on_Choices_Box_choice_selected(p_value: Variant) -> void:
	choice_selected.emit(p_value)
