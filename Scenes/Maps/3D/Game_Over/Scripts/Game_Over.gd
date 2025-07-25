extends MapBase3D

@export var _e_quotes_amount : Dictionary = {} # Match pm_key to amount

const _a_QUOTE_DIALOGUE_KEY = "Quote_%s_%s_1"

@onready var _a_Player = get_node("Objects/Player")
@onready var _a_Anims = get_node("Anims")

func _ready():
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)

func display_quote():
	var dialogue_system_si = Global.get_singleton(self, "Dialogue_System")
	var pm_key = _a_Player.comph().call_comp("Party_Member", "get_pm_key")
	var quotes_amount = _e_quotes_amount[pm_key]
	var rndm = randi() % quotes_amount + 1
	var dialogue_key = _a_QUOTE_DIALOGUE_KEY % [pm_key, rndm]
	dialogue_system_si.dialogue(dialogue_key)
	dialogue_system_si.set_dialogue_completed_cb(dialogue_key, _CB_dialogue_completed)

func _CB_dialogue_completed(p_key):
	if "Quote" in p_key:
		await get_tree().create_timer(1.0).timeout
		_a_Anims.play("Fall")

func load_data_init():
	super()
	
	var audio_manager_si = Global.get_singleton(self, "Audio_Manager")
	audio_manager_si.flatten_bgm()

func _on_anim_finished(p_anim_name):
	if p_anim_name == "Fall":
		var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
		var title_screen_scene_path = Global.get_title_screen_scene_path()
		scene_manager_si.change_scene_path(title_screen_scene_path)
