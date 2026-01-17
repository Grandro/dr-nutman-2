extends HBoxContainer
class_name SVEncounterIndicatorReactionEntry

@onready var _a_Image: TextureRect = get_node("Image")
@onready var _a_Text: Label = get_node("Text")

func set_texture_atlas(p_texture_atlas: Texture2D) -> void:
	var texture: AtlasTexture = _a_Image.get_texture()
	texture.set_atlas(p_texture_atlas)

func set_text(p_text: String) -> void:
	_a_Text.set_text(p_text)
