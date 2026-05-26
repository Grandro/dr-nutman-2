extends VBoxContainer
class_name FWSortBy

signal option_selected()

const _a_SORT_LOC_ID: String = "FW_SORT_%s_%s"

@export var _e_sort_args: Dictionary[StringName, StringName] = {} # Match key to sort method name
@export var _e_relations: Array[StringName] = [&"Low", &"High"]

@onready var _a_Options: OptionButton = get_node("Options")

func _ready() -> void:
	_a_Options.item_selected.connect(_on_Options_item_selected)
	
	_create_sort_types()

func _create_sort_types() -> void:
	var i: int = 0
	for key: StringName in _e_sort_args:
		var method_name: StringName = _e_sort_args[key]
		for rel: StringName in _e_relations:
			var loc_id: StringName = _a_SORT_LOC_ID % [key.to_upper(), rel.to_upper()]
			var metadata: Array[StringName]; metadata.assign([method_name, rel])
			_a_Options.add_item(tr(loc_id))
			_a_Options.set_item_metadata(i, metadata)
			i += 1

func get_selected_args() -> Array[StringName]:
	return _a_Options.get_selected_metadata()

func _on_Options_item_selected(_p_idx: int) -> void:
	option_selected.emit()
