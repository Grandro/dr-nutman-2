extends MainMenuSubMenuOptionsOptionTab
class_name MainMenuSubMenuOptionsAudio

@onready var _a_Volume: MainMenuSubMenuOptionsAudioVolume = get_node("HSplit/Left/Volume")

func load_data(p_data: Dictionary) -> void:
	_a_Volume.load_data(p_data[&"Volume"])
