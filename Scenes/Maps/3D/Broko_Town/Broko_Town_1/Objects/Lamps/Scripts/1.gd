extends Static3DObject

@onready var _a_Audio = get_node("Audio")
@onready var _a_Interactions = get_node("Interactions")
@onready var _a_Light = get_node("Light")

func _ready():
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)

func set_power(p_power):
	_a_Audio.play("Power_Switch")
	_a_Light.set_visible(p_power)

func get_save_data():
	var data = super()
	data["Power"] = _a_Light.is_visible()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Light.set_visible(p_data["Power"])

func _on_Interactions_interacted():
	var power = _a_Light.is_visible()
	set_power(!power)
