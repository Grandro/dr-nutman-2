extends Node3D
class_name CompSVStatus

const _a_TRIGGER_TYPES: Array[StringName] = [&"Turn_Start", &"Action_Pre_Event", &"Action_Post_Event"]
const _a_STATUS_ENTRY_SCENE_PATH: String = "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Comps/Status/Entries/%s.tscn"

@onready var _a_Status: HFlowContainer = get_node("Panel/VP/Status")

var _a_entity: SVCharacter = null

var _a_instances: Dictionary[StringName, SVStatusEntryBase] = {} # Match key to instance

func _ready() -> void:
	for child: SVStatusEntryBase in _a_Status.get_children():
		child.queue_free()

func init(p_entity: SVCharacter) -> void:
	_a_entity = p_entity

func handle_trigger_effects(p_trigger_type: StringName) -> void:
	_handle_trigger_effects_activation(p_trigger_type)
	_handle_trigger_effects_deactivation(p_trigger_type)

func add_status(p_key: StringName, p_amount: int) -> void:
	if _a_instances.has(p_key):
		var instance: SVStatusEntryBase = _a_instances[p_key]
		instance.change_amount(p_amount)
	else:
		var data: StatusData = Databases.get_data_entry("Status", p_key)
		var instance: SVStatusEntryBase = _instantiate_status_entry(p_key, p_amount, data)
		_a_instances[p_key] = instance
		_a_Status.add_child(instance)

func remove_status() -> void:
	pass

func _handle_trigger_effects_activation(p_trigger_type: StringName) -> void:
	for key: StringName in _a_instances:
		var instance: SVStatusEntryBase = _a_instances[key]
		var trigger_activation: StringName = instance.get_trigger_activation()
		if p_trigger_type != trigger_activation:
			continue
		
		instance.activate_trigger_effect()

func _handle_trigger_effects_deactivation(p_trigger_type: StringName) -> void:
	for key: StringName in _a_instances:
		var instance: SVStatusEntryBase = _a_instances[key]
		var trigger_deactivation: StringName = instance.get_trigger_deactivation()
		if p_trigger_type != trigger_deactivation:
			continue
		
		instance.deactivate_trigger_effect()

func _instantiate_status_entry(p_key: StringName, p_amount: int, p_data: StatusData) -> SVStatusEntryBase:
	var trigger_activation: StringName = p_data.get_trigger_activation()
	var trigger_deactivation: StringName = p_data.get_trigger_deactivation()
	var commands: Array[StringName] = p_data.get_commands()
	var stack: int = p_data.get_stack_()
	var init_effect: StatusEffect = p_data.get_init_effect()
	var trigger_effect: StatusEffect = p_data.get_trigger_effect()
	var scene: PackedScene = load(_a_STATUS_ENTRY_SCENE_PATH % p_key)
	var instance: SVStatusEntryBase = scene.instantiate()
	instance.tree_exited.connect(_on_Status_Entry_tree_exited.bind(p_key))
	instance.set_entity(_a_entity)
	instance.set_trigger_activation(trigger_activation)
	instance.set_trigger_deactivation(trigger_deactivation)
	instance.set_commands(commands)
	instance.set_stack(stack)
	instance.set_init_effect(init_effect)
	instance.set_trigger_effect(trigger_effect)
	instance.set_amount.call_deferred(p_amount)
	
	return instance

func _on_Status_Entry_tree_exited(p_key: StringName) -> void:
	_a_instances.erase(p_key)
