extends Static3DObject

@export var _e_destinations: Array = [] # (Array, Array, String)

@onready var _a_Interactions = get_node("Interactions")

func _ready():
	super()
	_a_Interactions.set_destinations(_e_destinations)
