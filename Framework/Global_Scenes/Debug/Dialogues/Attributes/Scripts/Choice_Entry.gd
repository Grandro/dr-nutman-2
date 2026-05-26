extends VBoxContainer
class_name FWDebugDialoguesAttributesChoiceEntry

signal up_pressed()
signal down_pressed()
signal delete_pressed()
signal loc_id_pressed()

@onready var _a_Up: TextureButton = get_node("HBox/Arrows/Up")
@onready var _a_Down: TextureButton = get_node("HBox/Arrows/Down")
@onready var _a_Heading: RichTextLabel = get_node("HBox/VBox/HBox/Heading")
@onready var _a_Delete: TextureButton = get_node("HBox/VBox/HBox/Delete")
@onready var _a_Loc_ID: Button = get_node("HBox/VBox/Loc_ID/Select")
@onready var _a_Value: FWDebugValueEdit = get_node("HBox/VBox/Value/Value_Edit")

func _ready() -> void:
	_a_Up.pressed.connect(_on_Up_pressed)
	_a_Down.pressed.connect(_on_Down_pressed)
	_a_Delete.pressed.connect(_on_Delete_pressed)
	_a_Loc_ID.pressed.connect(_on_Loc_ID_pressed)
	
	_a_Loc_ID.set_message_translation(false)

func set_heading(p_heading: String) -> void:
	_a_Heading.set_text("[u]%s" % p_heading)

func set_loc_id(p_loc_id: String) -> void:
	_a_Loc_ID.set_text(p_loc_id)

func set_value(p_value: Variant) -> void:
	_a_Value.set_value(p_value)

func get_value() -> Variant:
	return _a_Value.get_value()

func _on_Up_pressed() -> void:
	up_pressed.emit()

func _on_Down_pressed() -> void:
	down_pressed.emit()

func _on_Delete_pressed() -> void:
	delete_pressed.emit()

func _on_Loc_ID_pressed() -> void:
	loc_id_pressed.emit()
