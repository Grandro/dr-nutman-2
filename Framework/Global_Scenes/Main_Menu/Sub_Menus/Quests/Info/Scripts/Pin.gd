extends Button
class_name MainMenuSubMenuQuestsInfoPinPin

var _a_Pin_Texture: Texture2D = preload("uid://cmsctptdrp8n1")
var _a_Pinned_Texture: Texture2D = preload("uid://ckfywi27ph0ui")

func _ready() -> void:
	toggled.connect(_on_toggled)

func _on_toggled(p_toggled: bool) -> void:
	if p_toggled:
		set_text(tr(&"FW_PINNED"))
		set_button_icon(_a_Pinned_Texture)
	else:
		set_text(tr(&"FW_PIN"))
		set_button_icon(_a_Pin_Texture)
