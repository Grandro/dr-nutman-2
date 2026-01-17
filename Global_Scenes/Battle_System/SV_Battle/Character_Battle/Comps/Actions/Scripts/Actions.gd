extends Node3D
class_name CompSVActions

signal started()
signal finished()
signal pre_event()
signal post_event()
signal reaction_started()
signal reaction_finished()
signal hit()

@export var _e_commands: Dictionary[StringName, PackedScene] = {}
@export var _e_specials: Dictionary[StringName, PackedScene] = {}

@onready var _a_Commands: SVActionsBase = get_node("Commands")
@onready var _a_Specials: SVActionsBase = get_node("Specials")

func init(p_entity: SVCharacter) -> void:
	for child: Node3D in get_children():
		child.started.connect(_on_Action_started)
		child.finished.connect(_on_Action_finished)
		child.pre_event.connect(_on_Action_pre_event)
		child.post_event.connect(_on_Action_post_event)
		child.reaction_started.connect(_on_Action_reaction_started)
		child.reaction_finished.connect(_on_Action_reaction_finished)
		child.hit.connect(_on_Action_hit)
		child.init(p_entity)

func process_command(p_command: StringName) -> void:
	var scene: PackedScene = _e_commands[p_command]
	_a_Commands.process(scene)

func process_special(p_special: StringName) -> void:
	var scene: PackedScene = _e_specials[p_special]
	_a_Specials.process(scene)

func update_data(p_data: Dictionary) -> void:
	var actions_data: Dictionary = Databases.get_data(&"SV_Actions")
	var actions_commands: Dictionary[StringName, ActionData]; actions_commands.assign(actions_data[&"Commands"])
	var actions_specials: Dictionary[StringName, ActionData]; actions_specials.assign(actions_data[&"Specials"])
	_a_Commands.update_args(p_data[&"Commands"], actions_commands)
	_a_Specials.update_args(p_data[&"Specials"], actions_specials)

func get_commands_arg(p_command: StringName) -> ActionData:
	return _a_Commands.get_arg(p_command)

func get_specials_args() -> Dictionary[StringName, ActionData]:
	return _a_Specials.get_args()

func _on_Action_started() -> void:
	started.emit()

func _on_Action_finished() -> void:
	finished.emit()

func _on_Action_pre_event() -> void:
	pre_event.emit()

func _on_Action_post_event() -> void:
	post_event.emit()

func _on_Action_reaction_started() -> void:
	reaction_started.emit()

func _on_Action_reaction_finished() -> void:
	reaction_finished.emit()

func _on_Action_hit() -> void:
	hit.emit()
