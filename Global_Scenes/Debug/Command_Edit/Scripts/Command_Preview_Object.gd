extends DebugCommandEditCommandPreviewBase
class_name DebugCommandEditCommandPreviewObject

var _a_Outline_2D: ShaderMaterial = preload("res://Global_Resources/Materials/2D/Outline.tres")
var _a_Outline_Display_3D: ShaderMaterial = preload("res://Global_Resources/Materials/3D/Outline_Display.tres")

@onready var _a_Object: DebugObjectSelect = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Object")

var _a_revert_data: Dictionary = {} # objects revert data
var _a_object: Node = null # Selected object to erase material

func _ready() -> void:
	super()
	_a_Object.selected.connect(_on_Object_selected)

func open(p_instance: DebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	_a_revert_data = p_res_data[&"Objects"]
	
	_create_objects()
	_revert_objects()
	
	super(p_instance, p_data, p_res_data)

func _select_default_object(p_res_data: Dictionary) -> void:
	var key: StringName = p_res_data[&"Default_Object"]
	if key != &"" && _a_Object.has_key(key):
		_a_Object.select(key)

func _create_objects() -> void:
	var preview_vp: VP = get_preview_vp_instance()
	_a_Object.set_viewport(preview_vp)
	_a_Object.update_options()

func _revert_objects() -> void:
	for i: int in _a_Object.get_count():
		var instance: Node = _a_Object.get_value(i)
		var key: StringName = instance.comph().call_comp("Reference", &"get_key")
		if !_a_revert_data.has(key):
			continue
		
		var properties: Dictionary = _a_revert_data[key][&"Properties"]
		for comp_key: StringName in properties:
			for property: StringName in properties[comp_key]:
				_revert_object_property(instance, comp_key, property)
		
		if instance.comph().has_comp("Equipment"):
			var equipables: Dictionary = _a_revert_data[key][&"Equipables"]
			for group: StringName in equipables:
				_revert_object_equipable(instance, group)

func _set_object_revert_property_value(p_instance: Node, p_comp_key: StringName, p_property: StringName, p_value: Variant) -> void:
	var key: StringName = p_instance.comph().call_comp("Reference", &"get_key")
	var object_args: Dictionary = _a_revert_data.get_or_add(key, {})
	var properties_args: Dictionary = object_args.get_or_add(&"Properties", {})
	var comp_args: Dictionary[StringName, Variant]; comp_args.assign(properties_args.get_or_add(p_comp_key, {}))
	comp_args[p_property] = p_value

func _get_object_revert_comp_args(p_instance: Node, p_comp_key: StringName) -> Variant:
	var key: StringName = p_instance.comph().call_comp("Reference", &"get_key")
	var revert_args: Variant = _a_revert_data.get(key)
	if revert_args == null: return null
	var properties_args: Dictionary = _a_revert_data[key][&"Properties"]
	var comp_args: Variant = properties_args.get(p_comp_key)
	if comp_args == null: return null
	
	return comp_args

func _get_object_revert_property_value(p_instance: Node, p_comp_key: StringName, p_property: StringName) -> Variant:
	var comp_args: Variant = _get_object_revert_comp_args(p_instance, p_comp_key)
	if comp_args == null: return null
	if !comp_args.has(p_property): return null
	return comp_args[p_property]

func _revert_object_property(p_instance: Node, p_comp_key: StringName, p_property: StringName) -> void:
	var comp_args: Variant = _get_object_revert_comp_args(p_instance, p_comp_key)
	if comp_args == null: return
	if !comp_args.has(p_property): return
	
	var comp: Node = p_instance.comph().get_comp(p_comp_key)
	var property_args: PackedStringArray = p_property.split(".")
	var property_instance: Node = _get_property_instance(comp, property_args)
	var value: Variant = comp_args[p_property]
	var curr_value: Variant = property_instance.get(property_args[-1])
	if value != curr_value:
		property_instance.set(property_args[-1], value)
	
	if p_instance.comph().has_comp("Anims"):
		p_instance.comph().call_comp("Anims", &"update_anim")

func _get_property_instance(p_instance: Node, p_args: PackedStringArray) -> Node:
	var instance: Object = p_instance
	for i: int in p_args.size() - 1:
		instance = instance.get(p_args[i])
	
	return instance

func _set_object_revert_equipable(p_instance: Node, p_group: StringName) -> void:
	var key: StringName = p_instance.comph().call_comp("Reference", &"get_key")
	var equipable: StringName = p_instance.comph().call_comp("Equipment", &"get_equipable", [p_group])
	var object_args: Dictionary = _a_revert_data.get_or_add(key, {})
	var equipables_args: Dictionary[StringName, StringName]; equipables_args.assign(object_args.get_or_add(&"Equipables", {}))
	equipables_args[p_group] = equipable

func _revert_object_equipable(p_instance: Node, p_group: StringName) -> void:
	var key: StringName = p_instance.comph().call_comp("Reference", &"get_key")
	var equipables: Dictionary = _a_revert_data[key][&"Equipables"]
	var equipable: Variant = equipables.get(p_group)
	if equipable == null:
		return
	
	match equipable:
		&"": p_instance.comph().call_comp("Equipment", &"unequip", [p_group])
		_: p_instance.comph().call_comp("Equipment", &"equip", [p_group, equipable])

func _selected_object_changed() -> void:
	if _a_object != null:
		_activate_outline(_a_object, false)
	
	var selected: Node = _a_Object.get_selected_value()
	_activate_outline(selected, true)
	
	var curr_scene_dim: StringName = Scene_Manager.get_curr_scene_dim()
	var selected_dim: StringName = _get_object_dim(selected)
	if curr_scene_dim == selected_dim:
		var selected_pos: Variant = selected.get_position()
		_a_free_camera.set_position(selected_pos)
	
	if selected_dim == &"2D":
		var canvas_layer: CanvasLayer = selected.get_canvas_layer_node()
		if canvas_layer == null:
			_a_Preview.set_VP_size_2d_override(Vector2.ZERO)
		else:
			var base_vp_size: Vector2 = Global.get_base_vp_size()
			_a_Preview.set_VP_size_2d_override(base_vp_size)

func _activate_outline(p_instance: Node, p_activate: bool) -> void:
	var dim: StringName = _get_object_dim(p_instance)
	match dim:
		&"2D": _activate_outline_2D(p_instance, p_activate)
		&"3D": _activate_outline_3D(p_instance, p_activate)

func _activate_outline_2D(p_instance: Node, p_activate: bool) -> void:
	if !p_instance.comph().has_comp("Display"):
		return
	
	if p_activate:
		p_instance.comph().call_comp("Display", &"set_material", [_a_Outline_2D])
	else:
		p_instance.comph().call_comp("Display", &"set_material", [null])

func _activate_outline_3D(p_instance: Node, p_activate: bool) -> void:
	if p_activate:
		if p_instance.comph().has_comp("Display"):
			var outline_mat: ShaderMaterial = _prep_outline_display_3D(p_instance)
			p_instance.comph().call_comp("Display", &"set_material_override", [outline_mat])
		elif p_instance.comph().has_comp("Model"):
			pass
		else:
			pass
	else:
		if p_instance.comph().has_comp("Display"):
			p_instance.comph().call_comp("Display", &"set_material_override", [null])
		elif p_instance.comph().has_comp("Model"):
			pass
		else:
			pass

func _prep_outline_display_3D(p_instance: Node) -> ShaderMaterial:
	var outline_mat: ShaderMaterial = _a_Outline_Display_3D.duplicate()
	var texture: Texture2D = p_instance.comph().call_comp("Display", &"get_texture")
	outline_mat.set(&"shader_parameter/sprite_texture", texture)
	
	return outline_mat

func _get_object_dim(p_instance: Node) -> StringName:
	if p_instance is Node2D: return &"2D"
	elif p_instance is Node3D: return &"3D"
	
	return &""

func _grid_point_to_pos(p_point: Variant) -> Variant:
	var grid_step: Variant = _a_Grid_Step.get_value()
	var grid_start: Variant = _a_Grid_Offset.get_value()
	var pos: Variant = Global.grid_point_to_pos(p_point, grid_step, grid_start)
	
	return pos

func _pos_to_grid_point(p_pos: Variant) -> Variant:
	var grid_step: Variant = _a_Grid_Step.get_value()
	var grid_start: Variant = _a_Grid_Offset.get_value()
	var point: Variant = Global.pos_to_grid_point(p_pos, grid_step, grid_start)
	
	return point

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Object"] = _a_Object.get_save_data()
	data[&"Object"][&"Properties"] = {}
	data[&"Object"][&"Equipables"] = {}
	_adjust_object_properties(data[&"Object"][&"Properties"])
	_adjust_object_equipables(data[&"Object"][&"Equipables"])
	
	return data

func _adjust_object_properties(_p_properties: Dictionary) -> void:
	pass

func _adjust_object_equipables(_p_equipables: Dictionary) -> void:
	pass

func _on_Object_selected() -> void:
	_selected_object_changed()
