extends RigidBody3DObject
class_name RailCarBase

signal integrate_forces(p_state: PhysicsDirectBodyState3D)

var _a_force: float = 0.0

func _ready() -> void:
	super()
	set_physics_process(false)

func _physics_process(_p_delta: float) -> void:
	set_linear_velocity(global_transform.basis.x * _a_force)

func _integrate_forces(p_state: PhysicsDirectBodyState3D) -> void:
	integrate_forces.emit(p_state)

func set_force(p_force: float) -> void:
	_a_force = p_force
	set_linear_velocity(global_transform.basis.x * _a_force)
	set_physics_process(p_force != 0.0) 
