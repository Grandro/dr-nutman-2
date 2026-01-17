extends RailCarBase
class_name RailCarProjector

signal projector_power_changed(p_projector: ObjectProjectorBase, p_power: bool)

@onready var _a_Projector: ObjectProjectorBase = get_node("Projector")

func _ready() -> void:
	super()
	_a_Projector.power_changed.connect(_on_Projector_power_changed)
	_a_Projector.remove_from_group(&"Object")

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Projector"] = _a_Projector.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Projector.load_data(p_data[&"Projector"])

func load_data_init() -> void:
	_a_Projector.load_data_init()

func _on_Projector_power_changed(p_power: bool) -> void:
	projector_power_changed.emit(_a_Projector, p_power)
