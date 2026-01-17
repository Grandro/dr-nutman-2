extends Character3DObject
class_name Player3D

var _a_Shared: GDScript = preload("res://Scenes/Player/Scripts/Shared.gd")

var _a_shared: PlayerShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	super()
	
	_a_shared.ready()

func _input(p_event: InputEvent) -> void:
	_a_shared.input(p_event)
