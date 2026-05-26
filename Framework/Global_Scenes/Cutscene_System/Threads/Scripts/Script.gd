extends FWCutsceneThreadBase
class_name FWCutsceneThreadScript

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var instance_key: StringName = _a_args[&"Instance_Key"]
	var expression: String = _a_args[&"Expression"]
	var type: StringName = _a_args[&"Type"]
	var instance: Node
	match type:
		&"Object":
			var global_si: Global = Global.get_singleton(self, "Global")
			_a_object = global_si.get_object(instance_key)
			_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
			var comp: String = _a_args[&"Comp"]
			instance = _a_object.comph().get_comp(comp)
		&"Singleton":
			instance = Global.get_singleton(self, instance_key)
		&"Curr_Scene":
			instance = _a_curr_scene
	
	var expr: Expression = Expression.new()
	var error: Error = expr.parse(expression)
	if error == OK:
		expr.execute([], instance, true)
	else:
		print(expr.get_error_text())
	
	queue_free()
	_emit_completed()
	
	super()

func load_data(p_data: Dictionary) -> void:
	# Needed for when script saves data
	super(p_data)
	queue_free()
	_emit_completed()
