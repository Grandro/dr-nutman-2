extends Node2D
class_name CompSpeechBubble2D

signal choice_selected(p_value: Variant)

@export var _e_text_box_margin_screen: Vector2 = Vector2(8, 8)
@export var _e_arrow_margin_screen: Vector2 = Vector2(24, 24)

@onready var _a_Speech_Bubble_UI: CompSpeechBubbleUI = get_node("Speech_Bubble_UI")

var _a_text_box_pos_tl: Vector2 = Vector2.ZERO
var _a_text_box_pos_br: Vector2 = Vector2.ZERO
var _a_arrow_pos_tl: Vector2 = Vector2.ZERO
var _a_arrow_pos_br: Vector2 = Vector2.ZERO
var _a_inside_canvas: bool = false

func _ready() -> void:
	_a_Speech_Bubble_UI.choice_selected.connect(_on_Speech_Bubble_UI_choice_selected)
	
	_a_inside_canvas = get_canvas_layer_node() != null
	set_process(false)

func _process(_p_delta: float) -> void:
	_start()
	if !_a_inside_canvas:
		_2D_to_screen()
	_adjust_on_screen()
	if !_a_inside_canvas:
		_screen_to_2D()
	
	_a_Speech_Bubble_UI.set_global_position(_a_text_box_pos_tl)
	_a_Speech_Bubble_UI.set_arrow_global_pos(_a_arrow_pos_tl)

func init(p_entity: Node) -> void:
	var entity_comph: CompHandler = p_entity.comph()
	if entity_comph.has_comp("Interactions"):
		var interactions_comp: CompInteractions2D = entity_comph.get_comp("Interactions")
		interactions_comp.interaction_activated.connect(_on_Interactions_interaction_activated)

func open(p_ensure_visibility: bool) -> void:
	if p_ensure_visibility:
		set_process(true)
	_a_Speech_Bubble_UI.open()
	show()

func _close(p_fade_out: bool) -> void:
	set_process(false)
	if p_fade_out:
		hide()

func reset(p_fade_out: bool) -> void:
	_a_Speech_Bubble_UI.reset(p_fade_out)
	_close(p_fade_out)

func show_proceed_dot() -> void:
	_a_Speech_Bubble_UI.show_proceed_dot()

func open_choices_box(p_args: Dictionary) -> void:
	_a_Speech_Bubble_UI.open_choices_box(p_args)

func _start() -> void:
	var text_box_size_px: Vector2 = _a_Speech_Bubble_UI.get_size()
	var text_box_pos_br_px: Vector2 = Vector2(-132, -116) + Vector2(264, 96)
	var text_box_pos_tl_px: Vector2 = text_box_pos_br_px - text_box_size_px
	_a_text_box_pos_tl = to_global(text_box_pos_tl_px)
	_a_text_box_pos_br = to_global(text_box_pos_br_px)
	
	var arrow_size_px: Vector2 = _a_Speech_Bubble_UI.get_arrow_size() - Vector2(0.0, 3.0)
	var arrow_pos_tl_px: Vector2 = text_box_pos_tl_px
	arrow_pos_tl_px.x += text_box_size_px.x / 2.0 - arrow_size_px.x / 2.0
	arrow_pos_tl_px.y += text_box_size_px.y - 3.0
	var arrow_pos_br_px: Vector2 = arrow_pos_tl_px + arrow_size_px
	_a_arrow_pos_tl = to_global(arrow_pos_tl_px)
	_a_arrow_pos_br = to_global(arrow_pos_br_px)

func _2D_to_screen() -> void:
	var canvas_transform: Transform2D = get_viewport().get_canvas_transform()
	
	# Text_Box
	_a_text_box_pos_tl = canvas_transform * _a_text_box_pos_tl
	_a_text_box_pos_br = canvas_transform * _a_text_box_pos_br
	
	# Arrow
	_a_arrow_pos_tl = canvas_transform * _a_arrow_pos_tl
	_a_arrow_pos_br = canvas_transform * _a_arrow_pos_br

func _adjust_on_screen() -> void:
	var window_size: Vector2i = get_viewport().get_size()
	var text_box_size_screen: Vector2 = _a_text_box_pos_br - _a_text_box_pos_tl
	var arrow_size_screen: Vector2 = _a_arrow_pos_br - _a_arrow_pos_tl
	var arrow_flip_v: bool = false
	
	# Left_Out
	# Text_Box
	if _a_text_box_pos_tl.x < _e_text_box_margin_screen.x:
		var diff: float = _e_text_box_margin_screen.x - _a_text_box_pos_tl.x
		_a_text_box_pos_tl.x += diff
	
	# Arrow
	if _a_arrow_pos_tl.x < _e_arrow_margin_screen.x:
		_a_arrow_pos_tl.x = _e_arrow_margin_screen.x
	
	# Right Out
	# Text_Box
	if _a_text_box_pos_tl.x + text_box_size_screen.x > window_size.x - _e_text_box_margin_screen.x:
		var diff: float = _a_text_box_pos_tl.x + text_box_size_screen.x - window_size.x + _e_text_box_margin_screen.x
		_a_text_box_pos_tl.x -= diff
	
	# Arrow
	if _a_arrow_pos_tl.x + arrow_size_screen.x > window_size.x - _e_arrow_margin_screen.x:
		_a_arrow_pos_tl.x = window_size.x - arrow_size_screen.x - _e_arrow_margin_screen.x
	
	# Up Out
	# Text_Box
	if _a_text_box_pos_tl.y < _e_text_box_margin_screen.y:
		var diff: float = _e_text_box_margin_screen.y - _a_text_box_pos_tl.y
		_a_text_box_pos_tl.y += diff + arrow_size_screen.y
		_a_arrow_pos_tl.y = _e_text_box_margin_screen.y
		arrow_flip_v = true
	
	# Down Out
	# Arrow
	if _a_arrow_pos_tl.y + arrow_size_screen.y > window_size.y - _e_text_box_margin_screen.y:
		var diff: float = _a_arrow_pos_tl.y + arrow_size_screen.y - window_size.y + _e_text_box_margin_screen.y
		_a_text_box_pos_tl.y -= diff
		_a_arrow_pos_tl.y -= diff
	
	_a_Speech_Bubble_UI.set_arrow_flip_v(arrow_flip_v)

func _screen_to_2D() -> void:
	var canvas_transform: Transform2D = get_viewport().get_canvas_transform()
	_a_text_box_pos_tl = canvas_transform.affine_inverse() * _a_text_box_pos_tl
	_a_arrow_pos_tl = canvas_transform.affine_inverse() * _a_arrow_pos_tl

func set_text(p_text: String) -> void:
	_a_Speech_Bubble_UI.set_text(p_text)

func set_text_visible_characters(p_amount: int) -> void:
	_a_Speech_Bubble_UI.set_text_visible_characters(p_amount)

func get_text_visible_characters() -> int:
	return _a_Speech_Bubble_UI.get_text_visible_characters()

func get_text_length() -> int:
	return _a_Speech_Bubble_UI.get_text_length()

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_Interactions_interaction_activated(p_area: CompInteractionsInteraction2D) -> void:
	var speech_bubble_pos: Vector2 = p_area.get_speech_bubble_pos()
	set_position(speech_bubble_pos)

func _on_Speech_Bubble_UI_choice_selected(p_value: Variant) -> void:
	choice_selected.emit(p_value)
