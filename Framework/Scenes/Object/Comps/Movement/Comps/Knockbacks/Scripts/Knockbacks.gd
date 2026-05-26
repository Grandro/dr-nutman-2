extends Node
class_name FWCompMovementKnockbacks

signal started()
signal finished()

var _a_Knockback_Scene: PackedScene = preload("uid://clp2clj8wdf2j")

var _a_movement: Node

var _a_velocity: Variant # Vector

func _physics_process(_p_delta: float) -> void:
	_a_velocity = _a_movement.get_init_velocity()
	_process_knockbacks()

func init(p_entities: Array[Node]) -> void:
	_a_movement = p_entities[-1]
	
	_a_velocity = _a_movement.get_init_velocity()

func knockback(p_velocity: Variant) -> void:
	if get_child_count() == 0:
		started.emit()
	
	_instantiate_knockback(p_velocity)

func _instantiate_knockback(p_velocity: Variant) -> void:
	var instance: FWCompMovementKnockbacksKnockback = _a_Knockback_Scene.instantiate()
	instance.tree_exited.connect(_on_Knockback_tree_exited)
	instance.set_init_velocity(p_velocity)
	instance.set_wait_time(0.25)
	
	add_child(instance)

func _process_knockbacks() -> void:
	for child: FWCompMovementKnockbacksKnockback in get_children():
		var init_velocity: Variant = child.get_init_velocity()
		var end_velocity: Variant = _a_movement.get_init_velocity()
		var time_left: float = child.get_time_left()
		var duration: float = child.get_wait_time()
		var t: float = 1.0 - (time_left / duration)
		var velocity: Variant = init_velocity.lerp(end_velocity, t)
		_a_velocity += velocity

func reset_velocity() -> void:
	_a_velocity = _a_movement.get_init_velocity()
	for child: FWCompMovementKnockbacksKnockback in get_children():
		child.queue_free()

func adjust_velocity_post(p_velocity: Variant) -> Variant:
	return p_velocity

func get_velocity_() -> Variant:
	return _a_velocity

func get_speed() -> float:
	return 0.0

func _on_Knockback_tree_exited() -> void:
	if get_child_count() == 0:
		finished.emit()
