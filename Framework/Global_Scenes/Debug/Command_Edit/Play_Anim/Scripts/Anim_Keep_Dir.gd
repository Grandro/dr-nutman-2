extends FWDebugValueSelectOptions
class_name FWDebugCommandEditCommandPlayAnimKeepDir

const _a_DIR_NAMES: Array[StringName] = [&"Down", &"Left", &"Right", &"Up"]

var _a_cut_anims: Dictionary = {} # Match anims to cut_anim

func update_options() -> void:
	_clear_options()
	
	var anims: Dictionary = {}
	for anim: StringName in _e_options:
		var cut_anim: StringName = anim.substr(0, anim.rfind("_"))
		var has_dir: bool = false
		for dir_name: StringName in _a_DIR_NAMES:
			if "_" + dir_name in anim:
				has_dir = true
			if !anims.has(cut_anim):
				anims[cut_anim] = {}
			anims[cut_anim][dir_name] = anim
		
		if has_dir:
			_a_cut_anims[anims[cut_anim]] = cut_anim
		else:
			_a_cut_anims[anim] = cut_anim
	
	var keys: Array[StringName]; keys.assign(anims.keys())
	for i: int in keys.size():
		var key: StringName = keys[i]
		_a_option_idxs[key] = i
		_a_Value.add_item(key)
		_a_Value.set_item_metadata(i, anims[key])

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	var anims: Variant = get_selected_key()
	if anims == null:
		data[&"Value"] = null
	else:
		data[&"Value"] = _a_cut_anims[anims]
	
	return data
