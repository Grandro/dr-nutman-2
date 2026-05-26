extends FWMapBase3D
class_name MapGameOver

@export var _e_quotes_amount: Dictionary[StringName, int] = {} # Match pm_key to amount

const _a_QUOTE_DIALOGUE_KEY: String = "Quote_%s_%s_1"

@onready var _a_Player: FWPlayer3D = get_node("Objects/Player")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func _ready() -> void:
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)

func display_quote() -> void:
	var dialogue_system_si: Dialogue_System = Global.get_singleton(self, "Dialogue_System")
	var pm_key: StringName = _a_Player.comph().call_comp("Party_Member", &"get_pm_key")
	var quotes_amount: int = _e_quotes_amount[pm_key]
	var rndm: int = randi() % quotes_amount + 1
	var dialogue_key: StringName = _a_QUOTE_DIALOGUE_KEY % [pm_key, rndm]
	dialogue_system_si.dialogue(dialogue_key)
	dialogue_system_si.set_dialogue_completed_cb(dialogue_key, _CB_dialogue_completed)

func _CB_dialogue_completed(p_key: String) -> void:
	if "Quote" in p_key:
		await get_tree().create_timer(1.0).timeout
		_a_Anims.play(&"Fall")

func load_data_init() -> void:
	super()
	
	var audio_manager_si: Audio_Manager = Global.get_singleton(self, "Audio_Manager")
	audio_manager_si.flatten_bgm()

func _on_anim_finished(p_name: StringName) -> void:
	if p_name == &"Fall":
		var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
		var title_screen_scene_uid: String = Global.get_title_screen_scene_uid()
		scene_manager_si.change_scene_uid(title_screen_scene_uid)
