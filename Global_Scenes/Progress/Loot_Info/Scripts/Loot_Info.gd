extends Control
class_name ProgressLootInfo

@onready var _a_Rewards: LootRewardsLoot = get_node("Info/Margin/VBox/Rewards")
@onready var _a_Coins: LootCoins = get_node("Info/Coins")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")
@onready var _a_Audio_Start: AudioStreamPlayer = get_node("Audio/Start")

var _a_loot: Dictionary[StringName, int] = {} # Match item key to amount

func _ready() -> void:
	_a_Rewards.completed.connect(_on_Rewards_completed)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	set_process_input(false)
	hide()

func _input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Proceed_Dialogue"):
		_a_Anims.play(&"Fade_Out")

func open(p_loot: Dictionary[StringName, int]) -> void:
	_a_loot = p_loot
	Global.pause()
	
	_a_Coins.open(p_loot)
	
	_a_Audio_Start.play()
	_a_Anims.play(&"Fade_In")
	
	show()

func _close() -> void:
	set_process_input(false)
	_a_Rewards.close()
	Global.unpause()
	hide()

func _faded_in() -> void:
	_a_Rewards.open(_a_loot)

func _on_Rewards_completed() -> void:
	_a_Coins.count_up()
	set_process_input(true)

func _on_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fade_In": _faded_in()
		&"Fade_Out": _close()
