extends FWDebugCommandEditCommandBase
class_name FWDebugCommandEditCommandTeleport

@onready var _a_Type: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/VBox/Type")
@onready var _a_Teleportation: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/VBox/Teleportation")
@onready var _a_Destination: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/VBox/Destination")
@onready var _a_Troop: FWDebugValueSelectEdit = get_node("Window/Contents/Margin/VBox/Troop")
@onready var _a_Handle_Lost_Battle: FWDebugValueSelectBool = get_node("Window/Contents/Margin/VBox/Handle_Lost_Battle")

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()
	
	_a_Type.selected.connect(_on_Type_selected)
	_a_Teleportation.selected.connect(_on_Teleportation_selected)
	
	_a_Type.update_options()

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data: Dictionary) -> void:
	_a_Type.load_data_init()
	_selected_type_changed(false)
	_a_Teleportation.load_data_init()
	_selected_teleportation_changed()
	_a_Destination.load_data_init()
	_a_Troop.load_data_init()
	_a_Troop.expand(-1)
	_a_Handle_Lost_Battle.load_data_init()

func _open_load(p_data: Dictionary, _p_res_data: Dictionary) -> void:
	_a_Type.load_data(p_data[&"Type"])
	_selected_type_changed(false)
	_a_Teleportation.load_data(p_data[&"Teleportation"])
	_selected_teleportation_changed()
	_a_Destination.load_data(p_data[&"Destination"])
	_a_Troop.load_data(p_data[&"Troop"])
	_a_Handle_Lost_Battle.load_data(p_data[&"Handle_Lost_Battle"])

func _update_teleportations() -> void:
	var teleportation_location_keys: Array[StringName] = _get_teleportation_location_keys()
	_a_Teleportation.set_options(teleportation_location_keys)
	_a_Teleportation.update_options()

func _update_destinations() -> void:
	var destination_keys: Array[StringName] = _get_destination_keys()
	_a_Destination.set_options(destination_keys)
	_a_Destination.update_options()

func _selected_type_changed(p_update_troop_visible: bool = true) -> void:
	var type: StringName = _a_Type.get_selected_key()
	_a_Destination.set_visible(type == &"Map")
	_a_Handle_Lost_Battle.set_visible(type == &"Battle")
	if p_update_troop_visible:
		_update_troop_visible()
	
	_update_teleportations()
	_update_destinations()

func _selected_teleportation_changed() -> void:
	_update_troop_visible()
	_update_destinations()

func _update_troop_visible() -> void:
	var type: StringName = _a_Type.get_selected_key()
	match type:
		&"Map": 
			_a_Troop.set_visible(false)
		&"Battle":
			var tp: StringName = _a_Teleportation.get_selected_key()
			var data: SVEncounterData = Databases.get_data_entry(&"SV_Encounters", tp)
			var special: bool = data.get_special()
			_a_Troop.set_visible(!special)

func _get_teleportation_location_keys() -> Array[StringName]:
	var type: StringName = _a_Type.get_selected_key()
	var data: Dictionary
	match type:
		&"Map": data = Databases.get_data(&"Maps")
		&"Battle": data = Databases.get_data(&"SV_Encounters")
	var location_keys: Array[StringName]; location_keys.assign(data.keys())
	return location_keys

func _get_destination_keys() -> Array[StringName]:
	var type: StringName = _a_Type.get_selected_key()
	var args: Dictionary = {}
	match type:
		&"Map":
			var tp: StringName = _a_Teleportation.get_selected_key()
			var data: FWMapData = Databases.get_data_entry(&"Maps", tp)
			args = data.get_destinations()
	var destination_keys: Array[StringName]; destination_keys.assign(args.keys())
	return destination_keys

func _get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Type"] = _a_Type.get_save_data()
	data[&"Teleportation"] = _a_Teleportation.get_save_data()
	data[&"Destination"] = _a_Destination.get_save_data()
	data[&"Troop"] = _a_Troop.get_save_data()
	data[&"Handle_Lost_Battle"] = _a_Handle_Lost_Battle.get_save_data()
	
	return data

func _on_Type_selected() -> void:
	_selected_type_changed()

func _on_Teleportation_selected() -> void:
	_selected_teleportation_changed()
