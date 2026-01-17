extends DebugValueSelectOptions
class_name DebugChapterSelect

func update_options() -> void:
	_clear_options()
	
	var chapters: Array[StringName] = Progress.get_chapters()
	for i: int in chapters.size():
		var chapter: StringName = chapters[i]
		_a_option_idxs[chapter] = i
		_a_Value.add_item(chapter)
		_a_Value.set_item_metadata(i, chapter)
