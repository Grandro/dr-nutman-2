extends FWRigidBody3DObject
class_name ObjectCitrinBall

signal hit(p_instance: Node3D)

@onready var _a_Anims: FWCompAnims = get_node("Anims")
@onready var _a_Despawn: Timer = get_node("Despawn")

var _a_target: Node3D = null

func _ready() -> void:
	super()
	body_entered.connect(_on_body_entered)
	_a_Despawn.timeout.connect(_on_Despawn_timeout)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	set_contact_monitor(true)

func set_target(p_target: Node3D) -> void:
	_a_target = p_target

func _on_body_entered(p_body: Node3D) -> void:
	if p_body != _a_target:
		return
	
	set_contact_monitor.call_deferred(false)
	hit.emit(p_body)

func _on_Despawn_timeout() -> void:
	_a_Anims.play(&"Despawn")

func _on_Anims_anim_finished(_p_name: StringName) -> void:
	queue_free()
