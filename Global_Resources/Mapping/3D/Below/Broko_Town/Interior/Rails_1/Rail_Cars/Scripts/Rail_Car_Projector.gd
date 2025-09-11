extends "res://Global_Resources/Mapping/3D/Below/Broko_Town/Interior/Rails_1/Rail_Cars/Scripts/Rail_Car_Base.gd"

signal projector_power_changed(p_projector, p_power)

@onready var _a_Projector = get_node("Projector")

func _ready():
	super()
	_a_Projector.power_changed.connect(_on_Projector_power_changed)
	_a_Projector.remove_from_group("Object")

func get_save_data():
	var data = super()
	data["Projector"] = _a_Projector.get_save_data()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Projector.load_data(p_data["Projector"])

func load_data_init():
	_a_Projector.load_data_init()

func _on_Projector_power_changed(p_power):
	projector_power_changed.emit(_a_Projector, p_power)
