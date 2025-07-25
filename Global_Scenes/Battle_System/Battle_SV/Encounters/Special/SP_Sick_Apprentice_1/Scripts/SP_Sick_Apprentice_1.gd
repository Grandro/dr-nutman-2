extends "res://Global_Scenes/Battle_System/Battle_SV/Encounters/Scripts/Encounter_Base.gd"

@onready var _a_Bag = get_node("Objects/Bag")
@onready var _a_Disposable_Glove = get_node("Objects/Disposable_Glove")
@onready var _a_Popsicle_Stick = get_node("Objects/Popsicle_Stick")
@onready var _a_Pill = get_node("Objects/Pill")

func _ready():
	super()
	
	_a_Bag.hide()
	_a_Disposable_Glove.hide()
	_a_Popsicle_Stick.hide()
	_a_Pill.hide()

func load_data_init():
	var show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	if show_tutato_explain:
		var global_si = Global.get_singleton(self, "Global")
		var tutato_explain = global_si.get_tutato_explain("Explain_First_Battle")
		tutato_explain.completed.connect(_on_Tutato_Explain_completed)
		tutato_explain.open()
		
		_a_Command_Circle.set_enabled(false)

func _on_Tutato_Explain_completed():
	_a_Command_Circle.set_enabled(true)
