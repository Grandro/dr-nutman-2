extends MarginContainer
class_name SVStatusEntryBase

@onready var _a_Amount: Label = get_node("Amount")

var _a_entity: SVCharacter

var _a_trigger_activation: StringName
var _a_trigger_deactivation: StringName
var _a_commands: Array[StringName]
var _a_stack: int
var _a_amount: int
var _a_init_effect: StatusEffect
var _a_trigger_effect: StatusEffect

func _ready() -> void:
	_activate_init_effect()

func activate_trigger_effect() -> void:
	if _a_trigger_effect == null:
		return
	_a_trigger_effect.activate(_a_entity)

func deactivate_trigger_effect() -> void:
	if _a_trigger_effect == null:
		return
	_a_trigger_effect.deactivate(_a_entity)
	
	change_amount(-1)

func change_amount(p_amount: int) -> void:
	set_amount(_a_amount + p_amount)

func _activate_init_effect() -> void:
	if _a_init_effect != null:
		_a_init_effect.activate(_a_entity)

func set_entity(p_entity: SVCharacter) -> void:
	_a_entity = p_entity

func set_trigger_activation(p_trigger_activation: StringName) -> void:
	_a_trigger_activation = p_trigger_activation

func get_trigger_activation() -> StringName:
	return _a_trigger_activation

func set_trigger_deactivation(p_trigger_deactivation: StringName) -> void:
	_a_trigger_deactivation = p_trigger_deactivation

func get_trigger_deactivation() -> StringName:
	return _a_trigger_deactivation

func set_commands(p_commands: Array[StringName]) -> void:
	_a_commands = p_commands

func set_stack(p_stack: int) -> void:
	_a_stack = p_stack

func set_amount(p_amount: int) -> void:
	_a_amount = min(_a_stack, p_amount)
	_a_Amount.set_text(str(_a_amount))
	
	if p_amount == 0:
		queue_free()

func set_init_effect(p_init_effect: StatusEffect) -> void:
	_a_init_effect = p_init_effect

func set_trigger_effect(p_trigger_effect: StatusEffect) -> void:
	_a_trigger_effect = p_trigger_effect
