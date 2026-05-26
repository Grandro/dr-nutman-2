extends FWDebugCommandEditorEntryBranch
class_name FWDebugCommandEditorEntryLoop

# Breakable: 
func _ready() -> void:
	super()
	_a_Main.set_collapse_visible(true)

func add_res_data(p_res_data: Dictionary, p_args: Array = []) -> void:
	# Iterate n times over the entries and collect res_data
	var start: int = _a_data[&"Args"][&"Start"][&"Value"]
	var end: int = _a_data[&"Args"][&"End"][&"Value"]
	var step: int = _a_data[&"Args"][&"Step"][&"Value"]
	var iters: int = int(floor(end - start) / step) + 1
	
	if iters > 0:
		var end_idx: int = -1
		if !p_args.is_empty():
			end_idx = p_args[1]
		
		var entries: Array[FWDebugCommandEditorEntryBase] = get_entries(0)
		for i: int in iters:
			for j: int in entries.size():
				if i == iters - 1 && j == end_idx:
					break
				
				var entry: FWDebugCommandEditorEntryBase = entries[j]
				entry.add_res_data(p_res_data)
	else:
		push_warning("Loop doesn't terminate.")

func _update_display_main_base_args() -> void:
	var option_key: StringName = _a_data[&"Key"]
	var args: Dictionary = _a_data[&"Args"]
	
	var text: String = ""
	match option_key:
		&"For":
			var idx_text: String = _get_display_text(args[&"Idx"])
			var start_text: String = _get_display_text(args[&"Start"])
			var end_text: String = _get_display_text(args[&"End"])
			var step_text: String = _get_display_text(args[&"Step"])
			text += "%s = %s" % [idx_text, start_text]
			text += ", %s: %s" % [tr(&"DEBUG_CUTSCENES_END"), end_text]
			text += ", %s: %s" % [tr(&"DEBUG_CUTSCENES_STEP"), step_text]
	_a_Main.set_base_args(text)

func _update_branches() -> void:
	var margin: float = _get_main_arg_margin()
	var process_margin: Control = _a_Main.get_process_margin_instance()
	process_margin.custom_minimum_size.x = margin
	_a_Main.set_collapse_visible(true)
	_a_End.set_left_margin(margin)

func get_cutscene_data() -> Array[Dictionary]:
	var save_data: Dictionary = get_save_data()
	var data: Array[Dictionary] = [save_data]
	
	return data
