extends HBoxContainer
class_name MainMenuSubMenuPartyPortraits

signal entry_pressed(p_key: String, p_args: Dictionary)

const _a_ENTRY_SCENE_PATH: String = "res://Framework/Global_Scenes/Main_Menu/Sub_Menus/Party/Portraits/Entries/%s.tscn"
const _a_SELECTED_COLOR: Color = Color.WHITE
const _a_NORMAL_COLOR: Color = Color(0.5, 0.5, 0.5, 1.0)

var _a_selected: MainMenuSubMenuPartyPortraitEntryBase

func _ready() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var pm_data: Dictionary = global_si.get_party_members_active()
	for key: StringName in pm_data:
		var args: Dictionary = pm_data[key]
		var scene: PackedScene = load(_a_ENTRY_SCENE_PATH % key)
		var instance: MainMenuSubMenuPartyPortraitEntryBase = scene.instantiate()
		instance.pressed.connect(_on_Entry_pressed.bind(instance, args))
		
		add_child(instance)

func open(p_pm_key: StringName) -> void:
	for child: MainMenuSubMenuPartyPortraitEntryBase in get_children():
		var key: StringName = child.get_key()
		if p_pm_key == key:
			child.set_self_modulate(_a_SELECTED_COLOR)
			_a_selected = child
		else:
			child.set_self_modulate(_a_NORMAL_COLOR)

func _on_Entry_pressed(p_instance: MainMenuSubMenuPartyPortraitEntryBase, p_args: Dictionary) -> void:
	if _a_selected == p_instance:
		return
	
	var key: StringName = p_instance.get_key()
	entry_pressed.emit(key, p_args)
