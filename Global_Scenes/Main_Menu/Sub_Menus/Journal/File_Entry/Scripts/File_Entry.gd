extends VBoxContainer

signal select_pressed()
signal select_focus_entered()
signal select_focus_exited()

const _a_LOCATION_LOC_ID = "LOCATION_%s"
const _a_MINI_BUST_SCENE_PATH = "res://Global_Scenes/Main_Menu/Sub_Menus/Journal/File_Entry/Mini_Busts/%s.tscn"

@onready var _a_Mini_Busts = get_node("Mini_Busts")
@onready var _a_Margin = get_node("NinePatch/Margin")
@onready var _a_Play_Time = get_node("NinePatch/Margin/Grid/Play_Time/Value")
@onready var _a_Amethysts = get_node("NinePatch/Margin/Grid/Amethysts/Value")
@onready var _a_Location = get_node("NinePatch/Margin/Grid/Location/Value")
@onready var _a_Select = get_node("NinePatch/Select")

var _a_empty = false

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.focus_entered.connect(_on_Select_focus_entered)
	_a_Select.focus_exited.connect(_on_Select_focus_exited)

func update_display(p_data):
	var global_data = p_data["Singletons"]["Global"]
	var party_members = global_data["Party_Members"]
	_create_mini_busts(party_members)
	
	var play_time = Global.seconds_to_string(global_data["Play_Time"])
	var key_data = global_data["Inventory"]["Key"]
	var amethysts = 0
	if key_data.has("Amethyst"):
		amethysts = key_data["Amethyst"]["Amount"]
	var location = p_data["Singletons"]["Scene_Manager"]["Location"]
	
	_a_Play_Time.set_text(play_time)
	_a_Amethysts.set_text(str(amethysts))
	_a_Location.set_text(tr(_a_LOCATION_LOC_ID % location.to_upper()))

func grab_select_focus():
	_a_Select.grab_focus()

func _create_mini_busts(p_data):
	for key in p_data:
		var args = p_data[key]
		var active = args["Active"]
		if !active:
			continue
		
		var scene_path = _a_MINI_BUST_SCENE_PATH % key
		var scene = load(scene_path)
		var instance = scene.instantiate()
		_a_Mini_Busts.add_child(instance)

func set_empty(p_empty):
	_a_empty = p_empty
	_a_Margin.set_visible(!p_empty)

func is_empty():
	return _a_empty

func _on_Select_pressed():
	select_pressed.emit()

func _on_Select_focus_entered():
	select_focus_entered.emit()

func _on_Select_focus_exited():
	select_focus_exited.emit()
