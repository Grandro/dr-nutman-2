extends MarginContainer
class_name SVEncounterSpecialsMenu

signal selected(p_args: ActionData)
signal canceled()

const _a_ENTRY_SCENE_PATH: String = "res://Global_Scenes/Battle_System/Battle_SV/Encounters/Specials_Menu/Entries/%s.tscn"

@onready var _a_Desc: RichTextLabel = get_node("Panel/VBox/Desc")
@onready var _a_Entries: VBoxContainer = get_node("Panel/VBox/Entries")
@onready var _a_Audio_OK: AudioStreamPlayer = get_node("Audio/OK")
@onready var _a_Audio_Cancel: AudioStreamPlayer = get_node("Audio/Cancel")

func _ready() -> void:
	set_process_unhandled_input(false)
	hide()

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Cancel"):
		_a_Audio_Cancel.play()
		canceled.emit()
		_close()

func open(p_instance: SVPartyMember) -> void:
	_a_Desc.set_text("[center]%s" % tr(&"SV_ACTIONS_NONE_DESC"))
	
	var specials: Array[StringName] = p_instance.get_enabled_actions(&"Specials")
	var specials_args: Dictionary[StringName, ActionData] = p_instance.comph().call_comp("Actions", &"get_specials_args")
	for key: StringName in specials:
		var args: ActionData = specials_args[key]
		var name_: String = args.get_name_()
		var desc: String = args.get_desc()
		var SP_cost: int = args.get_SP_cost()
		var scene: PackedScene = load(_a_ENTRY_SCENE_PATH % key)
		var instance: SVEncounterSpecialsMenuEntry = scene.instantiate()
		instance.select_pressed.connect(_on_Entry_select_pressed.bind(args))
		instance.select_focus_entered.connect(_on_Entry_select_focus_entered.bind(desc))
		instance.set_name_text.call_deferred(name_)
		instance.set_SP_cost.call_deferred(SP_cost)
		
		_a_Entries.add_child(instance)
	
	if _a_Entries.get_child_count() > 0:
		var first: SVEncounterSpecialsMenuEntry = _a_Entries.get_child(0)
		first.grab_select_focus()
	
	set_process_unhandled_input(true)
	show()

func _close() -> void:
	set_process_unhandled_input(false)
	for child: SVEncounterSpecialsMenuEntry in _a_Entries.get_children():
		child.queue_free()
	
	hide()

func _on_Entry_select_pressed(p_args: ActionData) -> void:
	_close()
	_a_Audio_OK.play()
	selected.emit(p_args)

func _on_Entry_select_focus_entered(p_desc: String) -> void:
	_a_Desc.set_text("[center]%s" % p_desc)
