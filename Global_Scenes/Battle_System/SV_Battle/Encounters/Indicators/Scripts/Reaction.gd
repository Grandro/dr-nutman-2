extends CanvasLayer
class_name SVEncounterIndicatorReaction

const _a_BUTTON_TEXTURE_PATH: String = "res://Global_Resources/Sprites/SV/%s_Button_Spritesheet.png"
const _a_REACTION_LOC_ID: String = "SV_REACTIONS_%s"

var _a_Reaction_Entry_Scene: PackedScene = preload("uid://4a2m0e1hfpjg")

@onready var _a_Reactions_VBox: VBoxContainer = get_node("Reactions/VBox")
@onready var _a_Reactions_Anims: AnimationPlayer = get_node("Reactions/Anims")

func _ready() -> void:
	_a_Reactions_Anims.animation_finished.connect(_on_Reactions_Anims_anim_finished)
	
	hide()

func open(p_reactions: Dictionary[StringName, StringName]) -> void:
	for key: StringName in p_reactions:
		var button_key: StringName = p_reactions[key]
		var instance: SVEncounterIndicatorReactionEntry = _a_Reaction_Entry_Scene.instantiate()
		var texture: Texture2D = load(_a_BUTTON_TEXTURE_PATH % button_key)
		var loc_id: String = _a_REACTION_LOC_ID % key.to_upper()
		var text: String = tr(loc_id)
		instance.set_texture_atlas.call_deferred(texture)
		instance.set_text.call_deferred(text)
		
		_a_Reactions_VBox.add_child(instance)
	
	_a_Reactions_Anims.play(&"Fade_In")
	show()

func close() -> void:
	_a_Reactions_Anims.play(&"Fade_Out")

func _on_Reactions_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fade_Out":
			for child: SVEncounterIndicatorReactionEntry in _a_Reactions_VBox.get_children():
				child.queue_free()
			hide()
