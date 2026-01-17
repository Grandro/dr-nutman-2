extends Button
class_name MainMenuSubMenuQuestsInfoPinPin

var _a_Pin_Texture: Texture2D = preload("res://Global_Resources/Sprites/UI/Pin.png")
var _a_Pinned_Texture: Texture2D = preload("res://Global_Resources/Sprites/UI/Pinned.png")

func _ready() -> void:
	toggled.connect(_on_toggled)

func _on_toggled(p_toggled: bool) -> void:
	if p_toggled:
		set_text(tr(&"PINNED"))
		set_button_icon(_a_Pinned_Texture)
	else:
		set_text(tr(&"PIN"))
		set_button_icon(_a_Pin_Texture)
