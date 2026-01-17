extends StatusEffect
class_name StatusEffectStat

@export_enum("HP", "SP", "ATK", "MAG", "DEF", "SPEED", "LUCK") var _e_stat: String = "HP"
@export var _e_mult: float = 1.0
@export var _e_add: float = 0.0

func activate(p_entity: Node) -> void:
	p_entity.comph().call_comp("Stats", &"register_status_effect", [self])

func deactivate(p_entity: Node) -> void:
	p_entity.comph().call_comp("Stats", &"deregister_status_effect", [self])

func get_stat() -> StringName:
	return _e_stat

func get_modified_value(p_value: int) -> int:
	return int(_e_mult * p_value + _e_add)
