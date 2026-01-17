extends CanvasLayer
class_name DebugCommandsPreview

@onready var _a_Background: ColorRect = get_node("Background")
@onready var _a_Window: WindowControlBase = get_node("Window")
@onready var _a_Preview: DebugPreview = get_node("Window/Contents/Preview")

func _ready() -> void:
	_a_Window.hidden.connect(_on_Window_hidden)
	Debug.closing.connect(_on_Debug_closing)
	
	_a_Background.hide()
	_a_Window.hide()

func open(p_cutscene_data: Array[Dictionary], p_skip_idxs: Array[int]) -> void:
	_a_Preview.open()
	_a_Background.grab_focus()
	_a_Window.set_position(Vector2i.ZERO)
	
	await get_tree().process_frame
	
	var preview_scene: Node = _a_Preview.get_preview_scene()
	var cutscene_system_si: Cutscene_System = Global.get_singleton(preview_scene, "Cutscene_System")
	cutscene_system_si.cutscene_from_data(preview_scene, p_cutscene_data, &"Main", p_skip_idxs)
	
	_a_Background.show()
	_a_Window.show()

func _on_Window_hidden() -> void:
	_a_Preview.close()
	_a_Background.hide()

func _on_Debug_closing() -> void:
	_a_Window.hide()
