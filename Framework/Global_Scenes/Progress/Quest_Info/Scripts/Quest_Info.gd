extends Control
class_name FWProgressQuestInfo

const _a_CHAPTER_NAME_LOC_ID: String = "FW_PROGRESS_%s_NAME"
const _a_TYPE_LOC_ID: String = "FW_PROGRESS_QUEST_TYPE_%s"
const _a_STATUS_LOC_ID: String = "FW_PROGRESS_QUEST_INFO_STATUS_%s"

@onready var _a_Chapter: Label = get_node("Info/Margin/VBox/Heading/Chapter/Right")
@onready var _a_Name: Label = get_node("Info/Margin/VBox/Heading/Name")
@onready var _a_Type: Label = get_node("Info/Margin/VBox/Heading/Type")
@onready var _a_Rewards: VBoxContainer = get_node("Info/Margin/VBox/Rewards")
@onready var _a_Status: Label = get_node("Info/Margin/VBox/Status")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")
@onready var _a_Audio_Start: AudioStreamPlayer = get_node("Audio/Start")

var _a_status: StringName # Start/Complete

func _ready() -> void:
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	set_process_input(false)
	hide()

func _input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Proceed_Dialogue"):
		_a_Anims.play(&"Fade_Out")

func open(p_key: StringName, p_status: StringName) -> void:
	_a_status = p_status
	
	var global_si: Global = Global.get_singleton(self, "Global")
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var chapter: StringName = progress_si.get_chapter()
	global_si.pause()
	set_chapter(chapter)
	
	var data: FWQuestData = Databases.get_data_entry(&"Quests", p_key)
	var type: StringName = data.get_type()
	var name_: String = data.get_name_()
	_a_Type.set_text(tr(_a_TYPE_LOC_ID % type.to_upper()))
	_a_Name.set_text(tr(name_))
	_a_Status.set_text(tr(_a_STATUS_LOC_ID % p_status.to_upper()))
	
	match p_status:
		&"Start": _a_Rewards.hide()
		&"Complete": _a_Rewards.show()
	
	_a_Audio_Start.play()
	_a_Anims.play(&"Fade_In")
	
	show()

func _close() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	set_process_input(false)
	global_si.unpause()
	hide()

func _faded_in() -> void:
	match _a_status:
		&"Start": set_process_input(true)
		&"Complete": pass

func set_chapter(p_chapter: StringName) -> void:
	var text: String = _a_CHAPTER_NAME_LOC_ID % p_chapter.to_upper()
	_a_Chapter.set_text(text)

func _on_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fade_In": _faded_in()
		&"Fade_Out": _close()
