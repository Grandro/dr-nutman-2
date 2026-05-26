extends FWDebugEntryListEntry
class_name FWDebugEntryListActionEntry

signal preview_pressed(p_cutscene_data: Array[Dictionary])
signal option_test_selected(p_cutscene_data: Array[Dictionary], p_skip_idxs: Array[int])
signal selectable_focus_entered()

@onready var _a_Preview: Button = get_node("HBox/VBox/Margin/Margin/HBox/Preview")
@onready var _a_Editor: FWDebugCommandEditor = get_node("HBox/VBox/Options/Editor")

func _ready() -> void:
	super()
	_a_Preview.pressed.connect(_on_Preview_pressed)
	_a_Editor.option_test_selected.connect(_on_Editor_option_test_selected)
	_a_Editor.selectable_focus_entered.connect(_on_Editor_selectable_focus_entered)

func update_entries(p_data: Array[Dictionary]) -> void:
	_a_Editor.update_entries(p_data)

func set_editor_active(p_active: bool) -> void:
	_a_Editor.set_active(p_active)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Editor"] = _a_Editor.get_save_data()
	
	return data

func _on_Preview_pressed() -> void:
	var cutscene_data: Array[Dictionary] = _a_Editor.get_cutscene_data()
	preview_pressed.emit(cutscene_data)

func _on_Editor_option_test_selected(p_instance: FWDebugCommandEditorEntryBase) -> void:
	var cutscene_data: Array[Dictionary] = _a_Editor.get_cutscene_data()
	var skip_idxs: Array[int] = _a_Editor.get_skip_idxs(p_instance)
	option_test_selected.emit(cutscene_data, skip_idxs)

func _on_Editor_selectable_focus_entered() -> void:
	selectable_focus_entered.emit()
