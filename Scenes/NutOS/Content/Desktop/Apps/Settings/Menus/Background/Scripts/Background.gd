extends "res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Scripts/Menu_Base.gd"

@export var _e_bg_data: Array[Dictionary] = []

const _a_TYPES = ["Static"]
const _a_BACKGROUND_ENTRY_PATH = "res://Scenes/NutOS/Content/Desktop/Apps/Settings/Menus/Background/Background_Entry/%s.tscn"

@onready var _a_Type = get_node("VBox/VBox/Type/Options")
@onready var _a_Available = get_node("VBox/VBox/Static/Available/HFlow")

var _a_selected = null

func _ready():
	super()
	_create_type_options()

func open(p_data):
	var selected = "Nut_1"
	if !p_data.is_empty():
		_e_bg_data = p_data["BG_Data"]
		selected = p_data["Selected"]
	
	_update_available_backgrounds(selected)

func _create_type_options():
	for i in _a_TYPES.size():
		var type = _a_TYPES[i]
		var text = tr(type.to_upper())
		_a_Type.add_item(text)
		_a_Type.set_item_metadata(i, type)

func _update_available_backgrounds(p_selected):
	for child in _a_Available.get_children():
		child.queue_free()
	
	for args in _e_bg_data:
		var unlocked = args["Unlocked"]
		if !unlocked:
			continue
		
		var key = args["Key"]
		var selected = key == p_selected
		_instantiate_available_background(key, selected)

func _instantiate_available_background(p_key, p_selected):
	var scene = load(_a_BACKGROUND_ENTRY_PATH % p_key)
	var instance = scene.instantiate()
	instance.selected.connect(_on_Background_Entry_selected.bind(instance))
	instance.set_key(p_key)
	if p_selected:
		instance.select.call_deferred()
		_a_selected = instance
	
	_a_Available.add_child(instance)

func get_save_data():
	var data = {}
	data["BG_Data"] = _e_bg_data
	data["Selected"] = _a_selected.get_key()
	
	return data

func _on_Background_Entry_selected(p_instance):
	_a_selected.deselect()
	p_instance.select()
	_a_selected = p_instance
	
	var key = "Settings_Background"
	var texture = p_instance.get_texture()
	option_selected.emit(key, "Static_Background", texture)
