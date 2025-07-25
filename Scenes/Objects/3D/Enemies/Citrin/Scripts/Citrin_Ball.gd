extends RigidBody3DObject

signal hit(p_instance)

@onready var _a_Anims = get_node("Anims")
@onready var _a_Despawn = get_node("Despawn")

var _a_target = null

func _ready():
	super()
	body_entered.connect(_on_body_entered)
	_a_Despawn.timeout.connect(_on_Despawn_timeout)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	set_contact_monitor(true)

func set_target(p_target):
	_a_target = p_target

func _on_body_entered(p_body):
	if p_body != _a_target:
		return
	
	set_contact_monitor.call_deferred(false)
	hit.emit(p_body)

func _on_Despawn_timeout():
	_a_Anims.play("Despawn")

func _on_Anims_anim_finished(_p_anim_name):
	queue_free()
