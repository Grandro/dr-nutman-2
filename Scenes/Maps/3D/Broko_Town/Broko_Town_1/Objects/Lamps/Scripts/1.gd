extends Static3DObject

@onready var _a_Audio = get_node("Audio")
@onready var _a_Interactions = get_node("Interactions")
@onready var _a_Light = get_node("Light")

func _ready():
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)

func get_save_data():
	var data = super()
	data["Light_Enabled"] = _a_Light.is_visible()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Light.set_visible(p_data["Light_Enabled"])

func _on_Interactions_interacted():
	_a_Audio.play("Power_Switch")
	var is_active = _a_Light.is_visible()
	_a_Light.set_visible(!is_active)
