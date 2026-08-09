extends VBoxContainer
class_name FWDebugCommandEditorEntries

func get_entries_count(_p_branch_idx: int) -> int:
	return get_child_count()

func get_branch_entry(_p_branch_idx: int, p_idx: int) -> FWDebugCommandEditorEntryBase:
	return get_child(p_idx)

func get_entries() -> Array:
	return get_children()
