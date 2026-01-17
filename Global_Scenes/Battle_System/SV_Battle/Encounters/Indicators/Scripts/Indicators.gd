extends Node3D
class_name SVEncounterIndicators

@onready var _a_Enemy_Select: SVEncounterIndicatorEnemySelect = get_node("Enemy_Select")
@onready var _a_Command_Circle: SVEncounterIndicatorCommandCircle = get_node("Command_Circle")
@onready var _a_Reaction: SVEncounterIndicatorReaction = get_node("Reaction")
@onready var _a_Specials_Menu: SVEncounterIndicatorSpecialsMenu = get_node("Specials_Menu")

func open_enemy_select() -> void:
	_a_Enemy_Select.open()

func close_enemy_select() -> void:
	_a_Enemy_Select.close()

func update_enemy_select(p_instance: SVEnemy, p_init: bool) -> void:
	_a_Enemy_Select.update(p_instance, p_init)

func open_command_circle(p_pos: Vector3) -> void:
	_a_Command_Circle.open(p_pos)

func close_command_circle() -> void:
	_a_Command_Circle.close()

func open_reaction(p_reactions: Dictionary[StringName, StringName]) -> void:
	_a_Reaction.open(p_reactions)

func close_reaction() -> void:
	_a_Reaction.close()

func open_specials_menu() -> void:
	_a_Specials_Menu.open()

func close_specials_menu() -> void:
	_a_Specials_Menu.close()

func set_command_circle_command_text(p_text: String) -> void:
	_a_Command_Circle.set_command_text(p_text)
