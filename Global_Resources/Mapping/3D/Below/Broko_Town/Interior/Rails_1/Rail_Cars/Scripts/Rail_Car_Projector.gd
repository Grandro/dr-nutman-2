extends RailCarBase
class_name RailCarProjector

signal projector_power_changed(p_projector: ObjectProjectorBase, p_power: bool)

@export var _e_projector_name: String = "Projector"

@onready var _a_Projector: ObjectProjectorBase

func _ready() -> void:
	_a_Projector = get_node(_e_projector_name)
	
	super()
	_a_Projector.power_changed.connect(_on_Projector_power_changed)

func _on_Projector_power_changed(p_power: bool) -> void:
	projector_power_changed.emit(_a_Projector, p_power)
