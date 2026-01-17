extends NutOSContentDesktopAppSettingsMenuBase
class_name NutOSContentDesktopAppSettingsMenuBackground

@export var _e_bg_data: Array[Dictionary] = []

const _a_TYPES: Array[StringName] = [&"Static"]
const _a_BACKGROUND_ENTRY_PATH: String = "res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Background/Background_Entry/%s.tscn"

@onready var _a_Type: OptionButton = get_node("VBox/VBox/Type/Options")
@onready var _a_Available: HFlowContainer = get_node("VBox/VBox/Static/Available/HFlow")

var _a_selected: NutOSContentDesktopAppSettingsMenuBackgroundEntry

func _ready() -> void:
	super()
	_create_type_options()

func open(p_data: Dictionary) -> void:
	var selected: StringName = &"Nut_1"
	if !p_data.is_empty():
		_e_bg_data = p_data[&"BG_Data"]
		selected = p_data[&"Selected"]
	
	_update_available_backgrounds(selected)

func _create_type_options() -> void:
	for i: int in _a_TYPES.size():
		var type: StringName = _a_TYPES[i]
		var text: String = tr(type.to_upper())
		_a_Type.add_item(text)
		_a_Type.set_item_metadata(i, type)

func _update_available_backgrounds(p_selected: StringName) -> void:
	for child: NutOSContentDesktopAppSettingsMenuBackgroundEntry in _a_Available.get_children():
		child.queue_free()
	
	for args: Dictionary in _e_bg_data:
		var unlocked: bool = args[&"Unlocked"]
		if !unlocked:
			continue
		
		var key: StringName = args[&"Key"]
		var selected: bool = key == p_selected
		_instantiate_available_background(key, selected)

func _instantiate_available_background(p_key: StringName, p_selected: bool) -> void:
	var scene: PackedScene = load(_a_BACKGROUND_ENTRY_PATH % p_key)
	var instance: NutOSContentDesktopAppSettingsMenuBackgroundEntry = scene.instantiate()
	instance.selected.connect(_on_Background_Entry_selected.bind(instance))
	instance.set_key(p_key)
	if p_selected:
		instance.select.call_deferred()
		_a_selected = instance
	
	_a_Available.add_child(instance)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"BG_Data"] = _e_bg_data
	data[&"Selected"] = _a_selected.get_key()
	
	return data

func _on_Background_Entry_selected(p_instance: NutOSContentDesktopAppSettingsMenuBackgroundEntry) -> void:
	_a_selected.deselect()
	p_instance.select()
	_a_selected = p_instance
	
	var key: StringName = &"Settings_Background"
	var texture: Texture2D = p_instance.get_texture()
	option_selected.emit(key, &"Static_Background", texture)
