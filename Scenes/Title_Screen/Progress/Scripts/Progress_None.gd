extends FWTitleScreenProgressBase
class_name FWTitleScreenProgressNone

@onready var _a_Start: Button = get_node("VBox/Start")
@onready var _a_Load: Button = get_node("VBox/Load")
@onready var _a_Options: Button = get_node("VBox/Options")
@onready var _a_Credits: Button = get_node("VBox/Credits")
@onready var _a_Quit: Button = get_node("VBox/Quit")
@onready var _a_Version: Label = get_node("Version")

func _ready() -> void:
	super()
	
	_a_Start.pressed.connect(_on_Start_pressed)
	_a_Load.pressed.connect(_on_Load_pressed)
	_a_Options.pressed.connect(_on_Options_pressed)
	_a_Credits.pressed.connect(_on_Credits_pressed)
	_a_Quit.pressed.connect(_on_Quit_pressed)
	
	var global_si: Global = Global.get_singleton(self, &"Global")
	var version: StringName = global_si.get_version()
	_a_Version.set_text("v%s" % version)
	
	_a_Start.grab_focus()
