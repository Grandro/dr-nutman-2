extends Node3D
class_name ArcadeDot

signal player_entered()

@onready var _a_Area: Area3D = get_node("Area")

func _ready() -> void:
	_a_Area.body_entered.connect(_on_Area_body_entered)

func set_disabled(p_disabled: bool) -> void:
	_a_Area.set_monitoring.call_deferred(!p_disabled)
	set_visible(!p_disabled)

func _on_Area_body_entered(_p_body: FWPlayer3D) -> void:
	player_entered.emit()
