extends FWDebugDialoguesAttributeBase
class_name FWDebugDialoguesAttributeText

@onready var _a_General: FWDebugDialoguesAttributesTabGeneralTypes = get_node("General")
@onready var _a_Object: FWDebugDialoguesAttributesTextTabObject = get_node("Object")
@onready var _a_Pos: FWDebugDialoguesAttributesTextTabPos = get_node("Pos")
@onready var _a_Vox: FWDebugDialoguesAttributesTabVox = get_node("Vox")

func _ready() -> void:
	_a_General.type_changed.connect(_on_General_type_changed)
	_a_Object.object_selected.connect(_on_Object_object_selected)
	
	_set_tab_hidden(_a_Object, false)
	_set_tab_hidden(_a_Pos, true)
	set_current_tab(0)

func _to_type(p_type: StringName) -> void:
	var curr_tab: int = get_current_tab()
	_set_tab_hidden(_a_Object, p_type != &"Object")
	_set_tab_hidden(_a_Pos, p_type != &"Pos")
	set_current_tab(curr_tab)

func _on_General_type_changed(p_type: StringName) -> void:
	_to_type(p_type)

func _on_Object_object_selected(p_key: StringName) -> void:
	if !_a_Vox.get_object_edited():
		_a_Vox.select_object(p_key)
