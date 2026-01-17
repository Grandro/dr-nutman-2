extends Node3DObject
class_name Teleporter3D

signal teleported()

@export var _e_destination: Array[StringName] = []

@onready var _a_Interactions: CompInteractions3D = get_node("Interactions")

func _ready() -> void:
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)

func get_destination() -> Array[StringName]:
	return _e_destination

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Destination"] = _e_destination
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_e_destination = p_data[&"Destination"]

func _on_Interactions_interacted() -> void:
	teleported.emit()
