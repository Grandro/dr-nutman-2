extends FWCharacter3DObject
class_name ObjectEnemyBase

@export var _e_target: Node3D
@export var _e_stay_area: Area3D = null

@onready var _a_Behavior: FWObjectCompBehaviorBase = get_node("Behavior")

func _ready() -> void:
	_a_Behavior.set_target(_e_target)
	super()

func get_stay_area() -> Area3D:
	return _e_stay_area
