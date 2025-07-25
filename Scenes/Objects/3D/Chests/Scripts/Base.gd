extends "res://Scenes/Object/Scripts/Node3D_Object.gd"

@export var _e_loot : Dictionary = {} # [item_key][amount] = amount_in_pool

@onready var _a_Interactions = get_node("Interactions")
@onready var _a_Anims = get_node("Anims")

var _a_opened = false

func _ready():
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func get_save_data():
	var data = super()
	data["Opened"] = _a_opened
	
	return data

func load_data(p_data):
	super(p_data)
	_a_opened = p_data["Opened"]

func _on_Interactions_interacted():
	if !_a_opened:
		_a_Anims.play("Open")

func _on_Anims_anim_finished(p_name):
	match p_name:
		"Open":
			_a_opened = true
			_a_Interactions.set_interaction_allowed(false)
			
			var progress_si = Global.get_singleton(self, "Progress")
			var rolled_loot = Global.roll_loot(_e_loot)
			progress_si.open_loot_info(rolled_loot)
