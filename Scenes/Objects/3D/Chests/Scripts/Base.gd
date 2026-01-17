extends Node3DObject
class_name ObjectChestBase

@export var _e_loot: Dictionary = {} # [item_key][amount] = amount_in_pool

@onready var _a_Interactions: CompInteractions3D = get_node("Interactions")
@onready var _a_Anims: CompAnims = get_node("Anims")

var _a_opened: bool = false

func _ready() -> void:
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func _opened() -> void:
	_a_opened = true
	_a_Interactions.set_allowed(false)
	
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var rolled_loot: Dictionary[StringName, int] = Global.roll_loot(_e_loot)
	if !rolled_loot.is_empty():
		progress_si.open_loot_info(rolled_loot)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Opened"] = _a_opened
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_opened = p_data[&"Opened"]

func _on_Interactions_interacted() -> void:
	if !_a_opened:
		_a_Anims.play(&"Open")

func _on_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Open": _opened()
