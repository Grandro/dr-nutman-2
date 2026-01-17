extends DebugEntryListEntry
class_name DebugEntryListGroupEntry

@onready var _a_VBox: VBoxContainer = get_node("HBox/VBox")

var _a_entry_list = null

func _ready() -> void:
	_a_VBox.add_child(_a_entry_list)

func set_entry_list(p_entry_list) -> void:
	_a_entry_list = p_entry_list
