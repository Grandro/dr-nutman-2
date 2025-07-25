extends Node3DObject

@onready var _a_Interactions = get_node("Interactions")
@onready var _a_Trigger = get_node("Trigger")

var _a_vibrate = false
var _a_trigger_count = 0

func _ready():
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)
	_a_Trigger.timeout.connect(_on_Trigger_timeout)

func start_vibrate():
	comph().call_comp("Audio", "play", ["Vibrate"])
	_a_vibrate = true

func stop_vibrate():
	comph().call_comp("Audio", "stop", ["Vibrate"])
	_a_vibrate = false

func get_save_data():
	var data = super()
	data["Trigger"] = {}
	data["Trigger"]["Stopped"] = _a_Trigger.is_stopped()
	data["Trigger"]["Time_Left"] = _a_Trigger.get_time_left()
	data["Vibrate"] = _a_vibrate
	data["Trigger_Count"] = _a_trigger_count
	
	return data

func load_data(p_data):
	super(p_data)
	var stopped = p_data["Trigger"]["Stopped"]
	if !stopped:
		_a_Trigger.start(p_data["Trigger"]["Time_Left"])
	_a_vibrate = p_data["Vibrate"]
	_a_trigger_count = p_data["Trigger_Count"]

func _on_Interactions_interacted():
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	if _a_vibrate:
		# Turn off vibration
		cutscene_system_si.cutscene("Thermometer_1", "1")
		_a_Trigger.stop()
	else:
		# Turn on vibration
		cutscene_system_si.cutscene("Thermometer_1", "0")
		_a_Trigger.start()

func _on_Trigger_timeout():
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	match _a_trigger_count:
		0: cutscene_system_si.cutscene("Thermometer_1", "2", "Sub")
		1: cutscene_system_si.cutscene("Thermometer_1", "2", "Sub")
		2: cutscene_system_si.cutscene("Thermometer_1", "3", "Sub")
		3: cutscene_system_si.cutscene("Thermometer_1", "4", "Sub")
	
	_a_trigger_count += 1
