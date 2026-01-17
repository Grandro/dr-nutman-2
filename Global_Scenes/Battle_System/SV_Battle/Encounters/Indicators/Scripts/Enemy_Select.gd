extends Node3D
class_name SVEncounterIndicatorEnemySelect

const _a_ENEMY_LOC_ID: String = "ENEMY_%s_NAME"

@onready var _a_Button_Anims: AnimationPlayer = get_node("Sprites/Button/Anims")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")
@onready var _a_Canvas: CanvasLayer = get_node("Canvas")
@onready var _a_Enemy_Text: Label = get_node("Canvas/VBox/Enemy/Margin/Text")
@onready var _a_VBox_Anims: AnimationPlayer = get_node("Canvas/VBox/Anims")

func _ready() -> void:
	_a_VBox_Anims.animation_finished.connect(_on_VBox_Anims_anim_finished)
	
	_a_Canvas.hide()
	hide()

func open() -> void:
	_a_Button_Anims.play(&"Blink")
	_a_Anims.play(&"Indicate")
	_a_VBox_Anims.play(&"Fade_In")
	
	_a_Canvas.show()
	show()

func close() -> void:
	_a_Button_Anims.stop()
	_a_Anims.stop()
	_a_VBox_Anims.play(&"Fade_Out")

func update(p_instance: SVEnemy, p_init: bool) -> void:
	var pos: Vector3 = p_instance.get_global_position()
	var select_offset: Vector3 = p_instance.get_select_offset()
	var new_pos: Vector3 = pos + select_offset
	if p_init:
		set_global_position(new_pos)
	else:
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", pos + select_offset, 0.1)
	
	var enemy_key: StringName = p_instance.get_key()
	var text: String = _a_ENEMY_LOC_ID % enemy_key.to_upper()
	_a_Enemy_Text.set_text(text)

func _on_VBox_Anims_anim_finished(p_name: StringName) -> void:
	if p_name == &"Fade_Out":
		_a_Canvas.hide()
		hide()
