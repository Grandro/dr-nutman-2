extends "res://Global_Scenes/Battle_System/Battle_SV/Enemies/Ghosty/Comps/Actions/Commands/Scripts/Attack_ATK.gd"

@onready var _a_Delay = get_node("Delay")

func _ready():
	_a_Delay.timeout.connect()

func process():
	super()
