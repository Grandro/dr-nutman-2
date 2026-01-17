extends Control
class_name MainMenuSubMenuParty

signal closed(p_data: Dictionary)

@onready var _a_Selection: MainMenuSubMenuPartySelection = get_node("Selection")
@onready var _a_Status: MainMenuSubMenuPartyStatus = get_node("Status")

func _ready() -> void:
	_a_Selection.closed.connect(_on_Selection_closed)
	_a_Selection.entry_selected.connect(_on_Selection_entry_selected)
	_a_Status.closed.connect(_on_Status_closed)

func open(_p_data: Dictionary) -> void:
	_a_Selection.open()
	
	show()

func _close() -> void:
	queue_free()
	
	var data: Dictionary = {}
	closed.emit(data)

func _on_Selection_closed() -> void:
	_close()

func _on_Selection_entry_selected(p_pm_key: String, p_args: Dictionary) -> void:
	_a_Status.open_(p_pm_key, p_args)

func _on_Status_closed() -> void:
	_a_Selection.open()
