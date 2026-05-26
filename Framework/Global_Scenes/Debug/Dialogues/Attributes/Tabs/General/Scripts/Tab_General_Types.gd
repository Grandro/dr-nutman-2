extends FWDebugDialoguesAttributesTabGeneral
class_name FWDebugDialoguesAttributesTabGeneralTypes

signal type_changed(p_type: StringName)

@export var _e_types: Array[StringName] = []

const _a_TYPE_LOC_ID: String = "FW_DEBUG_DIALOGUES_ATTRIBUTES_%s"

@onready var _a_Type: OptionButton = get_node("Margin/HSplit/Left/Type/Options")

var _a_type_idxs: Dictionary[StringName, int] = {} # Match type to idx

func _ready() -> void:
	_a_Type.item_selected.connect(_on_Type_item_selected)
	
	_create_types()

func open(p_data: Dictionary) -> void:
	super(p_data)
	
	var type: StringName = p_data[&"Type"]
	var idx: int = _a_type_idxs[type]
	_a_Type.select(idx)
	
	type_changed.emit(type)

func open_init() -> void:
	super()
	
	var type: StringName = _e_types[0]
	var idx: int = _a_type_idxs[type]
	_a_Type.select(idx)
	
	type_changed.emit(type)

func _create_types() -> void:
	for i: int in _e_types.size():
		var type: StringName = _e_types[i]
		var loc_id: StringName = _a_TYPE_LOC_ID % type.to_upper()
		_a_type_idxs[type] = i
		_a_Type.add_item(tr(loc_id))
		_a_Type.set_item_metadata(i, type)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Type"] = _a_Type.get_selected_metadata()
	
	return data

func _on_Type_item_selected(p_idx: int) -> void:
	var type: StringName = _a_Type.get_item_metadata(p_idx)
	type_changed.emit(type)
