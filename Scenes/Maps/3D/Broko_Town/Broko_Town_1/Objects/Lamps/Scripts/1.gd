extends Static3DObject
class_name ObjectLamp1

@onready var _a_Audio: CompAudio3D = get_node("Audio")
@onready var _a_Interactions: CompInteractions3D = get_node("Interactions")
@onready var _a_Light: OmniLight3D = get_node("Light")

func _ready() -> void:
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)

func set_power(p_power: bool) -> void:
	_a_Audio.play("Power_Switch")
	_a_Light.set_visible(p_power)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Power"] = _a_Light.is_visible()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Light.set_visible(p_data[&"Power"])

func _on_Interactions_interacted() -> void:
	var power: bool = _a_Light.is_visible()
	set_power(!power)
