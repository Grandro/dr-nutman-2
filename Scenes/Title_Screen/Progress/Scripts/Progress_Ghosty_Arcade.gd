extends FWTitleScreenProgressNone

@onready var _a_Load_Autosave: Button = get_node("Load_Autosave")

func _ready() -> void:
	super()
	_a_Load_Autosave.pressed.connect(_on_Load_Autosave_pressed)

func _on_Load_Autosave_pressed() -> void:
	set_process_unhandled_input(false)
	var messages_si: Messages = Global.get_singleton(self, "Messages")
	messages_si.show_proceed(tr(&"FW_WRITE_READ_PROCEEDREAD"), _CB_Messages_Proceed)

func _CB_Messages_Proceed(p_response: StringName) -> void:
	match p_response:
		&"Yes":
			var save_file_idx: int = Global_Data.get_save_file_idx()
			var global_si: Global = Global.get_singleton(self, "Global")
			global_si.load_file_data(save_file_idx, "Auto")
		&"No":
			_a_Load_Autosave.grab_focus()
	
	set_process_unhandled_input(true)
