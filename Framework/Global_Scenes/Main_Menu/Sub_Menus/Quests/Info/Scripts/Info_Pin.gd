extends MainMenuSubMenuQuestsInfoBase
class_name MainMenuSubMenuQuestsInfoPin

signal pin_toggled(p_toggled: bool)

@onready var _a_Pin: Button = get_node("Margin/VBox/Pin")

func _ready() -> void:
	super()
	_a_Pin.toggled.connect(_on_Pin_toggled)

func display(p_key: StringName) -> void:
	super(p_key)
	
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var pinned: bool = progress_si.is_quest_pinned(p_key)
	_a_Pin.toggled.disconnect(_on_Pin_toggled)
	_a_Pin.set_pressed(pinned)
	_a_Pin.toggled.connect(_on_Pin_toggled)

func _on_Pin_toggled(p_toggled: bool) -> void:
	pin_toggled.emit(p_toggled)
