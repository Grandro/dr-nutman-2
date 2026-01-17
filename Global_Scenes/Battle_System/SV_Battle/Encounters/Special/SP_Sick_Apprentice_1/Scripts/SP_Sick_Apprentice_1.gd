extends SVEncounterBase
class_name SVEncounterSpecialSickApprentice1

@onready var _a_Bag: Node3DObject = get_node("Objects/Bag")
@onready var _a_Disposable_Glove: Node3DObject = get_node("Objects/Disposable_Glove")
@onready var _a_Popsicle_Stick: Node3DObject = get_node("Objects/Popsicle_Stick")
@onready var _a_Pill: Node3DObject = get_node("Objects/Pill")

func _ready() -> void:
	super()
	
	if !Global.is_instance_in_game_world(self):
		return
	
	_a_Bag.hide()
	_a_Disposable_Glove.hide()
	_a_Popsicle_Stick.hide()
	_a_Pill.hide()
	
	var show_tutato_explain: bool = Global_Data.get_options_gameplay_show_tutato_explain()
	if show_tutato_explain:
		var global_si: Global = Global.get_singleton(self, "Global")
		var tutato_explain: ObjectTutatoCompExplainFirstBattle2D = global_si.get_tutato_explain("Explain_First_Battle")
		tutato_explain.completed.connect(_on_Tutato_Explain_completed)
		tutato_explain.open()
		
		_a_Command_Circle.set_enabled(false)

func _on_Tutato_Explain_completed() -> void:
	_a_Command_Circle.set_enabled(true)
