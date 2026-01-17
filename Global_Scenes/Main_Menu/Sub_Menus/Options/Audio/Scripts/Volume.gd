extends VBoxContainer
class_name MainMenuSubMenuOptionsAudioVolume

@onready var _a_Master: DebugValueSelectSlider = get_node("Master")
@onready var _a_BGM: DebugValueSelectSlider = get_node("BGM")
@onready var _a_BGS: DebugValueSelectSlider = get_node("BGS")
@onready var _a_SFX: DebugValueSelectSlider = get_node("SFX")

func _ready() -> void:
	_a_Master.value_changed.connect(_on_Master_value_changed)
	_a_BGM.value_changed.connect(_on_BGM_value_changed)
	_a_BGS.value_changed.connect(_on_BGS_value_changed)
	_a_SFX.value_changed.connect(_on_SFX_value_changed)

func load_data(p_data: Dictionary) -> void:
	_a_Master.load_data(p_data[&"Master"])
	_a_BGM.load_data(p_data[&"BGM"])
	_a_BGS.load_data(p_data[&"BGS"])
	_a_SFX.load_data(p_data[&"SFX"])

func _on_Master_value_changed(p_value: float) -> void:
	Global_Data.set_options_audio_volume_master(p_value)

func _on_BGM_value_changed(p_value: float) -> void:
	Global_Data.set_options_audio_volume_BGM(p_value)

func _on_BGS_value_changed(p_value: float) -> void:
	Global_Data.set_options_audio_volume_BGS(p_value)

func _on_SFX_value_changed(p_value: float) -> void:
	Global_Data.set_options_audio_volume_SFX(p_value)
