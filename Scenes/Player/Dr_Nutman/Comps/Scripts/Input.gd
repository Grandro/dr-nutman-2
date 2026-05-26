extends Node
class_name PlayerDrNutmanCompInput

var _a_Operate: FWCompOperate
var _a_Interaction_System: FWPlayerCompInteractionSystem

func _input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Open_Main_Menu"):
		if Main_Menu.is_openable():
			var vp: Viewport = get_viewport()
			vp.set_input_as_handled()
			Main_Menu.open()
	
	elif p_event.is_action_pressed(&"OK"):
		var body: Node = _a_Interaction_System.get_body()
		if body != null:
			var vp: Viewport = get_viewport()
			vp.set_input_as_handled()
			
			var area: Node = _a_Interaction_System.get_area()
			body.comph().call_comp("Interactions", &"interaction", [area])

func init(p_entities: Array[Node]) -> void:
	var entity_comph: FWCompHandler = p_entities[-1].comph()
	_a_Operate = entity_comph.get_comp("Operate")
	_a_Interaction_System = entity_comph.get_comp("Interaction_System")
	
	_a_Operate.to_disabled.connect(_on_Operate_to_disabled)
	_a_Operate.to_enabled.connect(_on_Operate_to_enabled)

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_Operate_to_disabled() -> void:
	set_process_input(false)

func _on_Operate_to_enabled() -> void:
	set_process_input(true)
