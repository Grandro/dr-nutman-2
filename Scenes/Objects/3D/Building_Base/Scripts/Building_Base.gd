extends FWStatic3DObject
class_name ObjectBuildingBase

@export var _e_destinations: Array = [] # (Array, Array, StringName)

@onready var _a_Interactions: ObjectBuildingBaseCompInteractions = get_node("Interactions")

func _ready() -> void:
	super()
	_a_Interactions.set_destinations(_e_destinations)
