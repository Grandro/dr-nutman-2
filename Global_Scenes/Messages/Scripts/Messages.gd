extends CanvasLayer

@onready var _a_Control: Control = get_node("Control")
@onready var _a_Info: NinePatchRect = get_node("Control/Info")
@onready var _a_Info_Text: RichTextLabel = get_node("Control/Info/Margin/VBox/Text")
@onready var _a_Info_OK: Button = get_node("Control/Info/Margin/VBox/OK")
@onready var _a_Proceed: NinePatchRect = get_node("Control/Proceed")
@onready var _a_Proceed_Text: RichTextLabel = get_node("Control/Proceed/Margin/VBox/Text")
@onready var _a_Proceed_Yes: Button = get_node("Control/Proceed/Margin/VBox/HBox/Yes")
@onready var _a_Proceed_No: Button = get_node("Control/Proceed/Margin/VBox/HBox/No")

var _a_caller: Node
var _a_value: Variant

func _ready() -> void:
	_a_Info_OK.pressed.connect(_on_Info_OK_pressed)
	_a_Proceed_Yes.pressed.connect(_on_Proceed_Yes_pressed)
	_a_Proceed_No.pressed.connect(_on_Proceed_No_pressed)
	
	_a_Control.hide()
	_a_Info.hide()
	_a_Proceed.hide()

func update_trans() -> void:
	_a_Info_OK.set_text(tr(&"OK"))
	_a_Proceed_Yes.set_text(tr(&"YES"))
	_a_Proceed_No.set_text(tr(&"NO"))

func show_info(p_text: String, p_caller: Node = null, p_value: Variant = null) -> void:
	_a_caller = p_caller
	_a_value = p_value
	
	_a_Info_Text.set_text("[center]%s" % p_text)
	_a_Info_OK.grab_focus()
	_a_Control.show()
	_a_Info.show()

func show_proceed(p_text: String, p_caller: Node = null, p_value: Variant = null) -> void:
	_a_caller = p_caller
	_a_value = p_value
	
	_a_Proceed_Text.set_text("[center]%s" % p_text)
	_a_Proceed_No.grab_focus()
	_a_Control.show()
	_a_Proceed.show()

func _send_response(p_request: String, p_response: StringName = &"") -> void:
	if !is_instance_valid(_a_caller):
		return
	
	if _a_value == null:
		_a_caller.call(p_request, p_response)
	else:
		_a_caller.call(p_request, p_response, _a_value)

func _on_Info_OK_pressed() -> void:
	_a_Control.hide()
	_a_Info.hide()
	_send_response("MESSAGES_INFO")

func _on_Proceed_Yes_pressed() -> void:
	_a_Control.hide()
	_a_Proceed.hide()
	_send_response("MESSAGES_PROCEED", &"Yes")

func _on_Proceed_No_pressed() -> void:
	_a_Control.hide()
	_a_Proceed.hide()
	_send_response("MESSAGES_PROCEED", &"No")
