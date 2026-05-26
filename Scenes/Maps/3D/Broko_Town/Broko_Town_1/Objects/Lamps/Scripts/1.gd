extends FWStatic3DObject
class_name ObjectLamp1

@onready var _a_Audio: FWCompAudio3D = get_node("Audio")
@onready var _a_Interactions: FWCompInteractions3D = get_node("Interactions")
@onready var _a_Light: OmniLight3D = get_node("Light")

func _ready() -> void:
	super()
	_a_Interactions.interacted_empty.connect(_on_Interactions_interacted_empty)

func flip_power() -> void:
	var power: bool = _get_power()
	set_power(!power)

func set_power(p_power: bool) -> void:
	var power: bool = _get_power()
	if p_power == power:
		return
	
	_a_Audio.play("Power_Switch")
	_a_Light.set_visible(p_power)

func _get_power() -> bool:
	return _a_Light.is_visible()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Power"] = _a_Light.is_visible()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Light.set_visible(p_data[&"Power"])

func _on_Interactions_interacted_empty() -> void:
	flip_power()
