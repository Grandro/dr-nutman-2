extends MarginContainer
class_name FWDebugDatabases

const _a_KEY_LOC_ID: String = "FW_DEBUG_DATABASES_%s"

@onready var _a_Keys: VBoxContainer = get_node("HBox/Keys")
@onready var _a_Value: FWDebugValueEdit = get_node("HBox/Scroll/Value")

func _ready() -> void:
	for child: FWDebugDatabasesKeyEntry in _a_Keys.get_children():
		var key: StringName = child.get_key()
		child.pressed.connect(_on_Key_pressed.bind(key))

func update_trans() -> void:
	for child: FWDebugDatabasesKeyEntry in _a_Keys.get_children():
		var key: StringName = child.get_key()
		var loc_id: StringName = _a_KEY_LOC_ID % key.to_upper()
		child.set_text(tr(loc_id))

func _on_Key_pressed(p_key: StringName) -> void:
	var debug_data: Dictionary = Databases.get_data(&"Debug")
	var data: Dictionary = debug_data[p_key]
	_a_Value.set_value(data.duplicate(true))
