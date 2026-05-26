extends FWCharacter2DObject
class_name FWPlayer2D

@export var _e_comps: Dictionary[StringName, Array] = {}
@export var _e_key: StringName = &"Dr_Nutman"

var _a_Shared: GDScript = preload("uid://bvwo1l3wt1d8a")

var _a_shared: FWPlayerShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.set_comps(_e_comps)
	_a_shared.set_key(_e_key)
	_a_shared.ready()

func _input(p_event: InputEvent) -> void:
	_a_shared.input(p_event)
