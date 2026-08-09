extends Control
class_name MainMenuSubMenuPartySelection

signal closed()
signal entry_selected(p_key: StringName, p_args: Dictionary)

const _a_ENTRY_PATH: String = "res://Framework/Global_Scenes/Main_Menu/Sub_Menus/Party/Selection/%s.tscn"

@onready var _a_Back: FWIndicatorButton = get_node("Back")
@onready var _a_HBox: HBoxContainer = get_node("Margin/VBox/HBox")

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	for child: MainMenuSubMenuPartySelectionEntry in _a_HBox.get_children():
		child.queue_free()
	
	_instantiate_entries()
	set_process_unhandled_input(false)

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"ui_cancel"):
		close()

func open() -> void:
	await get_tree().process_frame
	var first: MainMenuSubMenuPartySelectionEntry = _a_HBox.get_child(0)
	first.grab_select_focus()
	
	set_process_unhandled_input(true)
	show()

func close() -> void:
	set_process_unhandled_input(false)
	closed.emit()
	hide()

func _instantiate_entries() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var pm_data: Dictionary = global_si.get_party_members_active()
	for key: StringName in pm_data:
		var args: Dictionary = pm_data[key]
		var instance: MainMenuSubMenuPartySelectionEntry = _instantiate_entry(key)
		instance.select_pressed.connect(_on_Entry_select_pressed.bind(key, args))
		
		_a_HBox.add_child(instance)

func _instantiate_entry(p_key: StringName) -> MainMenuSubMenuPartySelectionEntry:
	var scene: PackedScene = load(_a_ENTRY_PATH % p_key)
	var instance: MainMenuSubMenuPartySelectionEntry = scene.instantiate()
	
	return instance

func _on_Back_select_pressed() -> void:
	close()

func _on_Entry_select_pressed(p_key: StringName, p_args: Dictionary) -> void:
	entry_selected.emit(p_key, p_args)
	set_process_unhandled_input(false)
	hide()
