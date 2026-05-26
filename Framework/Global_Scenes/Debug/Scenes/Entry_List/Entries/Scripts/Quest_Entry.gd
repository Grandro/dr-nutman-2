extends FWDebugEntryListEntry
class_name FWDebugEntryListQuestEntry

var _a_Check_Image: Texture2D = preload("uid://bmqhddrlwm888")
var _a_Cross_Image: Texture2D = preload("uid://d7e78i6c344q")

@onready var _a_Completed: TextureRect = get_node("HBox/VBox/Margin/Margin/HBox/Completed")
@onready var _a_Sub_Quests: FWDebugQuestEntryList = get_node("HBox/VBox/Options/Sub_Quests/Entry_List")

var _a_key: StringName

func _ready() -> void:
	super()
	_a_Sub_Quests.entry_select_pressed.connect(_on_Sub_Quest_entry_select_pressed)
	
	var entry_scene: PackedScene = load("uid://dy7u1ocv26url")
	_a_Sub_Quests.set_entry_scene(entry_scene)

func update_data() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var quest_data_args: FWQuestData = Databases.get_data_entry("Quests", _a_key)
	var quest_data_obj: Array[FWObjectiveData] = quest_data_args.get_objectives()
	
	var quests_progress: Dictionary[StringName, FWProgressQuestBase] = progress_si.get_quests()
	var quest_progress: FWProgressQuestBase = quests_progress[_a_key]
	var quest_progress_obj: Array[Node] = quest_progress.get_objective_instances()
	
	var quest_name: String = tr(quest_data_args.get_name_())
	var quest_active: bool = quest_progress.is_active()
	_a_Name.set_text(quest_name)
	_set_completed(!quest_active)
	
	# Create Sub-Quests
	_a_Sub_Quests.clear_entries()
	
	var has_sub_quests: bool = false
	for i: int in quest_progress_obj.size():
		var data_obj_args: FWObjectiveData = quest_data_obj[i]
		var type: StringName = data_obj_args.get_type()
		if type != &"Sub_Quest":
			continue
		var sub_quest: FWQuestData = data_obj_args.get_sub_quest()
		var sub_quest_key: StringName = sub_quest.get_key()
		if !progress_si.is_quest_started(sub_quest_key):
			continue
		
		var instance: FWDebugEntryListEntry = _a_Sub_Quests.instantiate_entry_(sub_quest_key)
		_a_Sub_Quests.add_entry(instance)
		
		has_sub_quests = true
	
	_a_Collapse.set_visible(has_sub_quests)

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func _set_completed(p_completed: bool) -> void:
	if p_completed:
		_a_Completed.set_texture(_a_Check_Image)
	else:
		_a_Completed.set_texture(_a_Cross_Image)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Key"] = get_key()
	data[&"Sub_Quests"] = _a_Sub_Quests.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var sub_quests: Dictionary = p_data[&"Sub_Quests"]
	var sub_quests_keys: Array[StringName]; sub_quests_keys.assign(sub_quests.keys())
	for i: int in sub_quests_keys.size():
		var key: StringName = sub_quests_keys[i]
		var entry_args: Dictionary = sub_quests[key]
		var instance: FWDebugEntryListEntry = _a_Sub_Quests.get_entry(i)
		instance.load_data.call_deferred(entry_args)

func _on_Sub_Quest_entry_select_pressed(p_instance: FWDebugEntryListEntry) -> void:
	select_pressed.emit(p_instance)
