extends CanvasLayer
class_name FWDebugGeneralTeleportSceneSelect

var _a_HBox_Entry: PackedScene = preload("uid://degutg81re05c")
var _a_VBox_Entry: PackedScene = preload("uid://ddfpi7itcub0r")

@onready var _a_Return: Button = get_node("Control/VBox/Return")
@onready var _a_Teleportations_Heading: RichTextLabel = get_node("Control/VBox/Scroll/VBox/Teleportations/Heading")
@onready var _a_Teleportations: VBoxContainer = get_node("Control/VBox/Scroll/VBox/Teleportations/VBox")

func _ready() -> void:
	_a_Return.pressed.connect(_on_Return_pressed)
	Databases.data_loaded.connect(_on_Databases_data_loaded)
	
	update_trans()
	hide()

func update_trans() -> void:
	_a_Teleportations_Heading.set_text("[center][u]%s" % tr(&"DEBUG_GENERAL_TELEPORTATIONS"))

func open() -> void:
	show()

func close() -> void:
	hide()

func _create_teleport_list() -> void:
	var data: Dictionary = Databases.get_data(&"Maps")
	for key: StringName in data:
		var vbox_instance: FWDebugGeneralTeleportSceneVBoxEntry = _a_VBox_Entry.instantiate()
		vbox_instance.set_heading_text.call_deferred(key)
		
		for destination: StringName in data[key].get_destinations():
			var dest: Array[StringName] = [key, destination]
			var hbox_instance: FWDebugGeneralTeleportSceneHBoxEntry = _a_HBox_Entry.instantiate()
			hbox_instance.select_pressed.connect(_on_Normal_Select_pressed.bind(dest))
			hbox_instance.set_select_text.call_deferred(destination)
			
			vbox_instance.add_child(hbox_instance)
		_a_Teleportations.add_child(vbox_instance)

func _on_Return_pressed() -> void:
	close()

func _on_Databases_data_loaded() -> void:
	_create_teleport_list()

func _on_Normal_Select_pressed(p_dest: Array[StringName]) -> void:
	Scene_Manager.change_scene_dest(p_dest)
	Debug.close()
	close()
