extends FWDebugCommandEditorEntryCommand
class_name FWDebugCommandEditorEntryShowOverlay

const _a_TRANS_MASKS_PATH: String = "res://Global_Resources/Sprites/Overlays/Trans"

# Breakable: [&"Mask"], [&"Anim"]
func _update_warnings_add() -> void:
	var type: StringName = _a_data[&"Type"][&"Value"]
	match type:
		&"Trans":
			var mask_path: String = _a_data[&"Mask"][&"Value"]
			if !FileAccess.file_exists(mask_path):
				var filters: PackedStringArray = PackedStringArray(["*.png"])
				var args: WarningArgsFile = WarningArgsFile.new(mask_path, [&"Mask"], _a_TRANS_MASKS_PATH, filters)
				_a_warnings.push_back(args)
			
			var anim: StringName = _a_data[&"Anim"][&"Value"]
			if !Global.has_trans_anim(anim):
				var args: WarningArgsStringName = WarningArgsStringName.new(anim, [&"Anim"])
				_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var type: StringName = _a_data[&"Type"][&"Value"]
	var mask_path: String = _a_data[&"Mask"][&"Value"]
	var mask_file: String = mask_path.get_file()
	var anim_text: String = _get_display_text(_a_data[&"Anim"])
	
	var text: String = tr("FW_DEBUG_CUTSCENES_%s" % type.to_upper())
	match type:
		&"Trans":
			text += ", %s" % mask_file
	text += ", %s" % anim_text
	_a_Main.set_base_args(text)
