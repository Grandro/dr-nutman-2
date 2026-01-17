extends Node3D
class_name BattlePopup

@onready var _a_Text: Label3D = get_node("Pos/Text")
@onready var _a_Anims: AnimationPlayer = get_node("Pos/Text/Anims")

func _ready() -> void:
	_a_Anims.animation_finished.connect(_on_anim_finished)
	_a_Anims.play(&"Fade_Out")

func set_text(p_text: String) -> void:
	_a_Text.set_text(p_text)

func set_modulate(p_color: Color) -> void:
	_a_Text.set_modulate(p_color)

func _on_anim_finished(_p_name: StringName) -> void:
	queue_free()
