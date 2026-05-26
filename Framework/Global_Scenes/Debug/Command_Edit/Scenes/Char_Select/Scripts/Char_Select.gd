extends FWDebugValueSelectText
class_name FWDebugCommandEditValueSelectChar

@export var _e_pattern: String = "[a-z]"
@export var _e_ord_min: int = 97
@export var _e_ord_max: int = 122
@export var _e_ord: int = 97

var _a_regex: RegEx = RegEx.new()
var _a_taken_idx_ords: Array[int] = []
var _a_text: String = ""

func _ready() -> void:
	super()
	_a_regex.compile(_e_pattern)

func set_taken_idx_ords(p_taken_idx_ords: Array[int]) -> void:
	_a_taken_idx_ords = p_taken_idx_ords

func load_data_init() -> void:
	super()
	var idx_ord: int = _e_ord
	while _a_taken_idx_ords.has(idx_ord):
		idx_ord = max((idx_ord + 1) % (_e_ord_max + 1), _e_ord_min)
	_a_Value.set_text(char(idx_ord))
	_a_text = _a_Value.get_text()

func _on_Value_text_changed(p_text: String) -> void:
	var res: RegExMatch = _a_regex.search(p_text)
	if res == null:
		_a_Value.set_text("")
		return
	if p_text.is_empty():
		return
	
	var idx_ord: int = p_text.to_utf8_buffer()[0]
	if _a_taken_idx_ords.has(idx_ord):
		_a_Value.set_text(_a_text)
		return
	
	_a_text = p_text
