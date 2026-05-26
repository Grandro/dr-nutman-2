extends FWDebugValueSelect
class_name FWDebugValueSelectText

signal text_changed(p_text: String)

@onready var _a_Value: LineEdit = get_node("Value")

func _ready() -> void:
	super()
	_a_Value.text_changed.connect(_on_Value_text_changed)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_Value.get_text()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.set_text(p_data[&"Value"])

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Value.set_editable(!p_toggled)

func _on_Value_text_changed(p_text: String) -> void:
	text_changed.emit(p_text)
