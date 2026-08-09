extends FWMainMenuMenuBase
class_name MainMenuMenuMain

@onready var _a_Back: FWIndicatorButton = get_node("Margin/VBox/HBox/Back")
@onready var _a_Titlescreen: Button = get_node("Margin/VBox/HBox/Titlescreen")
@onready var _a_Menu_Icons: HFlowContainer = get_node("Margin/VBox/Menu_Icons")
@onready var _a_Coins: Label = get_node("Margin/VBox/Coins/Text")

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	_a_Titlescreen.pressed.connect(_on_Titlescreen_pressed)
	
	var global_si: Global = Global.get_singleton(self, "Global")
	var coins: int = global_si.get_coins()
	_a_Coins.set_text(str(coins))
	
	_init_menu_icons(_a_Menu_Icons)

func _on_Back_select_pressed() -> void:
	close()

func _on_Titlescreen_pressed() -> void:
	var messages_si: Messages = Global.get_singleton(self, "Messages")
	messages_si.show_proceed(tr(&"FW_MAIN_MENU_UNSAVEDWARNING"), _CB_Messages_Proceed)
	set_process_unhandled_input(false)

func _CB_Messages_Proceed(p_response: StringName) -> void:
	if p_response == &"Yes":
		var main_menu_si: Main_Menu = Global.get_singleton(self, "Main_Menu")
		var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
		var title_screen_scene_uid: String = Global.get_title_screen_scene_uid()
		main_menu_si.close()
		scene_manager_si.change_scene_uid(title_screen_scene_uid)
	
	set_process_unhandled_input(true)
