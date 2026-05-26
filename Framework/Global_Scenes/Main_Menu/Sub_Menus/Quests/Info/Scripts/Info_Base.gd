extends PanelContainer
class_name MainMenuSubMenuQuestsInfoBase

signal back_pressed()

@export var _e_show_back: bool = false

const _a_OBJECTIVE_SCENE_PATH: String = "res://Global_Scenes/Main_Menu/Sub_Menus/Quests/Info/Objective_%s.tscn"

@onready var _a_Back: Button = get_node("Margin/VBox/Back")
@onready var _a_Heading: RichTextLabel = get_node("Margin/VBox/VBox/VBox/Heading")
@onready var _a_Desc: RichTextLabel = get_node("Margin/VBox/VBox/VBox/Desc")
@onready var _a_Objectives: VBoxContainer = get_node("Margin/VBox/VBox/Objectives")

var _a_key: StringName # Quest key

func _ready() -> void:
	_a_Back.pressed.connect(_on_Back_pressed)
	
	_a_Back.set_visible(_e_show_back)

func display(p_key: StringName) -> void:
	_a_key = p_key
	_clear_objectives()
	
	var quest_args: FWQuestData = Databases.get_data_entry(&"Quests", p_key)
	var quest_name: String = tr(quest_args.get_name_())
	var quest_desc: String = tr(quest_args.get_desc())
	_a_Heading.set_text("[center]%s" % quest_name)
	_a_Desc.set_text("[center]%s" % quest_desc)
	
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var quests_progress: Dictionary[StringName, FWProgressQuestBase] = progress_si.get_quests()
	var quest_progress: FWProgressQuestBase = quests_progress[p_key]
	var quest_progress_obj: Array[Node] = quest_progress.get_objective_instances()
	for instance: FWProgressQuestObjectiveBase in quest_progress_obj:
		_instantiate_objective(instance)
	
	show()

func close() -> void:
	_a_key = &""
	hide()

func _clear_objectives() -> void:
	for child: MainMenuSubMenuQuestsInfoObjectiveBase in _a_Objectives.get_children():
		child.queue_free()

func _instantiate_objective(p_objective_instance: FWProgressQuestObjectiveBase) -> void:
	var data: FWObjectiveData = p_objective_instance.get_data()
	var type: StringName = data.get_type()
	var scene: PackedScene = load(_a_OBJECTIVE_SCENE_PATH % type)
	var instance: MainMenuSubMenuQuestsInfoObjectiveBase = scene.instantiate()
	instance.set_objective_instance(p_objective_instance)
	
	_a_Objectives.add_child(instance)

func is_quest_open(p_key: StringName) -> bool:
	return _a_key == p_key

func get_key() -> StringName:
	return _a_key

func _on_Back_pressed() -> void:
	back_pressed.emit()
