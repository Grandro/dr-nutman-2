extends CutsceneThreadBase
class_name CutsceneThreadWait

@onready var _a_Timer: Timer = get_node("Timer")

var _a_time: float

func _ready() -> void:
	super()
	_a_Timer.timeout.connect(_on_Timer_timeout)
	
	if !_a_loads_data:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		_a_time = cutscene_system_si.get_option_value(_a_args[&"Time"])
		_process_command()

func skip() -> void:
	super()
	
	_a_Timer.stop()
	
	_emit_completed()
	queue_free()

func _process_command() -> void:
	_a_Timer.start(_a_time)
	
	super()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	var args: Dictionary = data[&"Args"]
	args[&"Time"] = _a_Timer.get_time_left()
	
	return data

func load_data(p_data: Dictionary):
	super(p_data)
	
	var args: Dictionary = p_data[&"Args"]
	_a_time = args[&"Time"]
	
	_process_command()

func _on_Timer_timeout() -> void:
	if !_a_skip:
		_emit_completed()
		queue_free()
