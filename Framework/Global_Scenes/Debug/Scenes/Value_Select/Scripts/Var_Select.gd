extends HBoxContainer
class_name FWDebugValueSelectVarSelect

signal active_toggled(p_toggled: bool)

@onready var _a_Active: CheckBox = get_node("Active")
@onready var _a_Select: Button = get_node("Select")
@onready var _a_Canvas: CanvasLayer = get_node("Canvas")
@onready var _a_Panel: PanelContainer = get_node("Canvas/Panel")
@onready var _a_Expression: FWDebugExpressionBase = get_node("Canvas/Panel/Margin/Expression")

func _ready() -> void:
	_a_Active.toggled.connect(_on_Active_toggled)
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Select.set_disabled(true)
	_a_Expression.update_instances()
	
	_a_Canvas.hide()

func is_active() -> bool:
	return _a_Active.is_pressed()

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Active"] = _a_Active.is_pressed()
	data[&"Expression"] = _a_Expression.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_Active.set_pressed(p_data[&"Active"])
	_a_Expression.load_data(p_data[&"Expression"])

func load_data_init() -> void:
	_a_Active.set_pressed(false)
	_a_Expression.load_data_init()

func _on_Active_toggled(p_toggled: bool) -> void:
	_a_Select.set_disabled(!p_toggled)
	if !p_toggled:
		_a_Canvas.hide()
	active_toggled.emit(p_toggled)

func _on_Select_pressed() -> void:
	if _a_Canvas.is_visible():
		_a_Canvas.hide()
	else:
		var offset: Vector2 = get_global_position()
		offset.x -= _a_Panel.get_size().x
		_a_Canvas.set_offset(offset)
		
		_a_Canvas.show()
