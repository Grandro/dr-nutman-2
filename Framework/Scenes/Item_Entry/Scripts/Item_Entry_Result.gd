extends FWItemEntryLoot
class_name FWItemEntryResult

signal anim_finished(p_name: StringName)

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func _ready() -> void:
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)

func play_anim(p_name: StringName):
	_a_Anims.play(p_name)

func _on_anim_finished(p_name: StringName) -> void:
	anim_finished.emit(p_name)
