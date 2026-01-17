extends NutOSContentDesktopApp
class_name NutOSContentDesktopAppColorSelection

@onready var _a_Color_Selection: MiniGameColorSelection = get_node("Color_Selection")

func _ready() -> void:
	super()
	_a_Color_Selection.closed.connect(_on_Color_Selection_closed)

func open(_p_save_data: Dictionary) -> void:
	_a_Color_Selection.open()

func _on_Color_Selection_closed() -> void:
	_close()

func _on_close_requested() -> void:
	_a_Color_Selection.close()
