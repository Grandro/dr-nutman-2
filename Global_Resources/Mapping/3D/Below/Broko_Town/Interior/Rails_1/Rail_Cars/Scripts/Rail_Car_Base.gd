extends RigidBody3DObject

signal integrate_forces(p_state)

var _a_force = 0.0

func _ready():
	super()
	set_physics_process(false)

func _physics_process(_p_delta):
	set_linear_velocity(global_transform.basis.x * _a_force)

func _integrate_forces(p_state):
	integrate_forces.emit(p_state)

func set_force(p_force):
	_a_force = p_force
	set_linear_velocity(global_transform.basis.x * _a_force)
	set_physics_process(p_force != 0.0)
