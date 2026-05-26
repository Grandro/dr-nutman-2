extends FWStatic3DObject
class_name ObjectSetup

@onready var _a_Computer: ObjectSetupComputer = get_node("Computer")
@onready var _a_Keyboard: ObjectSetupKeyboard = get_node("Keyboard")
@onready var _a_Monitor_Screen: Sprite3D = get_node("Monitor/Screen")
@onready var _a_NutOS: NutOS = get_node("Canvas/NutOS")
@onready var _a_Disk_Drive: ObjectSetupDiskDrive = get_node("Canvas/Disk_Drive")

func _ready() -> void:
	super()
	_a_NutOS.shutdown.connect(_on_NutOS_shutdown)
	_a_NutOS.app_option_selected.connect(_on_NutOS_app_option_selected)
	_a_Disk_Drive.slot_inserted.connect(_a_NutOS._on_Disk_Drive_slot_inserted)
	_a_Disk_Drive.slot_removed.connect(_a_NutOS._on_Disk_Drive_slot_removed)

func _process(_p_delta: float) -> void:
	var tex: ViewportTexture = _a_NutOS.get_vp_texture()
	_a_Monitor_Screen.set_texture(tex)

func turn_nutOS_on() -> void:
	_a_Computer.turn_on()
	_a_Keyboard.turn_on()
	_a_NutOS.boot()
	
	set_process(true)

func _turn_nutOS_off() -> void:
	set_process(false)
	_a_Computer.turn_off()
	_a_Keyboard.turn_off()
	_a_Monitor_Screen.set_texture(null)

func open_disk_drive() -> void:
	_a_Disk_Drive.open()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Keyboard"] = _a_Keyboard.get_save_data()
	data[&"NutOS"] = _a_NutOS.get_save_data()
	data[&"Disk_Drive"] = _a_Disk_Drive.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	var nutOS_active: bool = p_data[&"NutOS"][&"Active"]
	if nutOS_active:
		set_process(true)

	_a_Keyboard.load_data(p_data[&"Keyboard"])
	_a_NutOS.load_data(p_data[&"NutOS"])
	_a_Disk_Drive.load_data(p_data[&"Disk_Drive"])

func load_data_init() -> void:
	set_process(false)
	_a_NutOS.load_data_init()

func _on_NutOS_shutdown() -> void:
	_turn_nutOS_off()

func _on_NutOS_app_option_selected(p_key: StringName, p_option: StringName, p_value: Variant) -> void:
	match p_key:
		&"Settings_Keyboard":
			match p_option:
				&"Static_Color":
					var color: Color = p_value[0]
					var is_fav_color: bool = p_value[1]
					_a_Keyboard.set_static_color(color, is_fav_color)
