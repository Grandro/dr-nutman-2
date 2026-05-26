extends FWDebugEntryList
class_name FWDebugQuestEntryList

func _ready() -> void:
	super()
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	progress_si.progress_changed.connect(_on_Progress_progress_changed)

func instantiate_entries() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var quests_data: Dictionary = Databases.get_data(&"Quests")
	var quests_progress: Dictionary[StringName, FWProgressQuestBase] = progress_si.get_quests()
	for key: StringName in quests_progress:
		var quest_data: FWQuestData = quests_data[key]
		var type: StringName = quest_data.get_type()
		if type == &"Main" || type == &"Side":
			var instance: FWDebugEntryListQuestEntry = instantiate_entry_(key)
			add_entry(instance)

func instantiate_entry_(p_key: StringName = &"") -> FWDebugEntryListQuestEntry:
	var instance: FWDebugEntryListQuestEntry = instantiate_entry(p_key)
	instance.set_key(p_key)
	instance.update_data.call_deferred()
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> FWDebugEntryListQuestEntry:
	var key: StringName = p_data[&"Key"]
	var instance: FWDebugEntryListQuestEntry = instantiate_entry_(key)
	
	return instance

func delete_entry(p_key: String) -> void:
	var instance: FWDebugEntryListQuestEntry = _a_entries[p_key]
	instance.queue_free()

func has_entry(p_key: String) -> bool:
	return _a_entries.has(p_key)

func _on_Progress_progress_changed() -> void:
	for child: FWDebugEntryListQuestEntry in get_entries():
		child.update_data()
