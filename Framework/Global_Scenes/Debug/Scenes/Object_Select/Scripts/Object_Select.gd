extends FWDebugValueSelectOptions
class_name FWDebugObjectSelect

const _a_ICON_TEXTURE_PATH: String = "res://Framework/Global_Resources/Sprites/Debug/Classes/%s.png"

@export var _e_needed_comps: Array[String] = ["Reference"]
@export var _e_allowed_classes: Array[StringName] = [&"Node"]

var _a_vp: Viewport

func _ready() -> void:
	super()
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)

func update_options() -> void:
	_clear_options()
	
	var instances: Array[Node] = Global.get_objects_vp(_a_vp, _e_needed_comps, _e_allowed_classes)
	var i: int = 0
	for instance: Node in instances:
		var key: StringName = instance.comph().call_comp("Reference", &"get_key")
		var icon: Texture2D = _get_object_icon(instance)
		
		_a_options[key] = instance
		_a_option_idxs[key] = i
		_a_Value.add_icon_item(icon, key)
		_a_Value.set_item_metadata(i, key)
		i += 1

func set_allowed_classes(p_allowed_classes: Array[StringName]) -> void:
	_e_allowed_classes = p_allowed_classes

func get_allowed_classes() -> Array[StringName]:
	return _e_allowed_classes

func set_viewport(p_vp: Viewport) -> void:
	_a_vp = p_vp

func _get_object_icon(p_instance: Node) -> Texture2D:
	var script: Script = p_instance.get_script()
	var base_type: StringName = script.get_instance_base_type()
	var icon: Texture2D = load(_a_ICON_TEXTURE_PATH % base_type)
	
	return icon

func _on_Scene_Manager_scene_changed(_p_instance: Node, _p_loaded_file_data: bool) -> void:
	update_options()
