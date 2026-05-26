extends FWCharacter3DObject
class_name FWPlayer3D

@export var _e_base_comps: Dictionary[StringName, Dictionary] = {}
@export var _e_override_comps: Dictionary[StringName, Dictionary] = {}
@export var _e_key: StringName = &"Dr_Nutman"

var _a_Shared: GDScript = preload("uid://bvwo1l3wt1d8a")

var _a_shared: FWPlayerShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.init_comps(_e_base_comps, _e_override_comps)
	_a_shared.set_key_init(_e_key)
	_a_shared.ready()

func get_comps() -> Dictionary[StringName, Dictionary]:
	return _a_shared.get_comps()

func set_key(p_key: StringName) -> void:
	_a_shared.set_key(p_key)

func get_key() -> StringName:
	return _a_shared.get_key()
