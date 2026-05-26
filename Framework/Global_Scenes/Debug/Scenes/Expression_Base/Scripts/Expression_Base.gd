extends HBoxContainer
class_name FWDebugExpressionBase

@export var _e_create_curr_scene: bool = false
@export var _e_create_objects: bool = false
@export var _e_create_singletons: bool = false

@onready var _a_Instance: OptionButton = get_node("VBox/VBox/HBox/Instance/Options")
@onready var _a_Execute: Button = get_node("VBox/VBox/HBox/Execute")
@onready var _a_Comp_HBox: HBoxContainer = get_node("VBox/VBox/Comp")
@onready var _a_Comp: OptionButton = get_node("VBox/VBox/Comp/Options")
@onready var _a_Expression_Value: LineEdit = get_node("VBox/VBox/Expression/VBox/Value")
@onready var _a_Expression_Error: Label = get_node("VBox/VBox/Expression/VBox/Error")
@onready var _a_Attributes: Button = get_node("VBox/VBox/Attributes")

var _a_self_key: StringName
var _a_self: Node
var _a_instance_idxs: Dictionary[StringName, int] = {} # Match instance key to idx
var _a_comp_idxs: Dictionary[StringName, int] = {} # Match comp key to idx
var _a_keys_idx: int # only key instances can be removed or added -> save last idx before singletons
var _a_instance: Node
var _a_attr_select: FWDebugAttrSelect

func _ready() -> void:
	_a_Instance.item_selected.connect(_on_Instance_item_selected)
	_a_Comp.item_selected.connect(_on_Comp_item_selected)
	_a_Execute.pressed.connect(_on_Execute_pressed)
	_a_Attributes.pressed.connect(_on_Attributes_pressed)
	
	_a_attr_select = Debug.get_attr_select()

func update_self(p_self_key: StringName) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_self_key = p_self_key
	_a_self = global_si.get_object(p_self_key)

func update_instances() -> void:
	_a_Instance.clear()
	_a_instance_idxs.clear()
	
	var idx: int = 0
	if is_instance_valid(_a_self):
		var metadata: _Instance_Metadata = _Instance_Metadata.new(_a_self_key, _a_self, &"Object")
		_a_Instance.add_item("Self")
		_a_Instance.set_item_metadata(idx, metadata)
		_a_instance_idxs[&"$Self"] = idx
		idx += 1
	
	if _e_create_curr_scene:
		var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
		var curr_scene: Node = scene_manager_si.get_curr_scene_instance()
		var metadata: _Instance_Metadata = _Instance_Metadata.new(&"$Curr_Scene", curr_scene, &"Curr_Scene")
		_a_Instance.add_item("Curr_Scene")
		_a_Instance.set_item_metadata(idx, metadata)
		_a_instance_idxs[&"$Curr_Scene"] = idx
		idx += 1
	
	if _e_create_objects:
		var global_si: Global = Global.get_singleton(self, "Global")
		var instances: Array[Node] = global_si.get_all_objects(["Reference"])
		for instance: Node in instances:
			if instance == _a_self:
				continue
			var key: StringName = instance.comph().call_comp("Reference", &"get_key")
			if key == &"" || _a_instance_idxs.has(key):
				continue
			
			var metadata: _Instance_Metadata = _Instance_Metadata.new(key, instance, &"Object")
			_a_Instance.add_item(key)
			_a_Instance.set_item_metadata(idx, metadata)
			_a_instance_idxs[key] = idx
			idx += 1
	
	_a_keys_idx = idx
	
	if _e_create_singletons:
		var root: Window = get_tree().get_root()
		for i: int in root.get_child_count() - 1:
			var child: Node = root.get_child(i)
			var key: StringName = child.get_name() # Singletons have no key
			var metadata: _Instance_Metadata = _Instance_Metadata.new(key, child, &"Singleton")
			_a_Instance.add_item(key)
			_a_Instance.set_item_metadata(idx, metadata)
			_a_instance_idxs[key] = idx
			idx += 1

func _update_expression_error(p_expression: String) -> void:
	var metadata: _Instance_Metadata = _a_Instance.get_selected_metadata()
	var instance: Node = metadata.get_instance()
	if !is_instance_valid(instance):
		_a_Expression_Error.set(&"theme_override_colors/font_color", Color.WHITE)
		_a_Expression_Error.set_text(tr(&"DEBUG_EXPRESSION_NO_INSTANCE"))
		return
	
	var expr: Expression = Expression.new()
	var error: Error = expr.parse(p_expression)
	var error_text: String = ""
	if error == OK:
		var type: StringName = metadata.get_type()
		if type == &"Object":
			var comp: StringName = _a_Comp.get_selected_metadata()
			instance = instance.comph().get_comp(comp)
		
		var res: Variant = expr.execute([], instance, false)
		if expr.has_execute_failed():
			_a_Expression_Error.set(&"theme_override_colors/font_color", Color.RED)
			error_text = tr(&"DEBUG_EXPRESSION_EXECUTE_FAILED")
		else:
			_a_Expression_Error.set(&"theme_override_colors/font_color", Color.GREEN)
			error_text = "%s!: %s" % [tr(&"DEBUG_EXPRESSION_SUCCESS"), res]
	else:
		_a_Expression_Error.set(&"theme_override_colors/font_color", Color.RED)
		error_text = expr.get_error_text()
	
	_a_Expression_Error.set_text(error_text)

func _selected_instance_changed() -> void:
	var metadata: _Instance_Metadata = _a_Instance.get_selected_metadata()
	var instance: Node = metadata.get_instance()
	var type: StringName = metadata.get_type()
	
	var is_object: bool = type == &"Object"
	_a_Comp_HBox.set_visible(is_object)
	if is_object:
		_update_comps(instance)
		var comp: StringName = _a_Comp.get_selected_metadata()
		instance = instance.comph().get_comp(comp)
	
	_a_instance = instance

func _selected_comp_changed() -> void:
	var metadata: _Instance_Metadata = _a_Instance.get_selected_metadata()
	var comp: StringName = _a_Comp.get_selected_metadata()
	var instance: Node = metadata.get_instance()
	_a_instance = instance.comph().get_comp(comp)

func _update_comps(p_instance: Node) -> void:
	_a_Comp.clear()
	_a_comp_idxs.clear()
	
	var comps: Dictionary[StringName, Node] = p_instance.comph().get_comps()
	var comp_keys: Array[StringName] = comps.keys()
	for i: int in comp_keys.size():
		var comp: StringName = comp_keys[i]
		_a_comp_idxs[comp] = i
		_a_Comp.add_item(comp)
		_a_Comp.set_item_metadata(i, comp)

func get_self_key() -> StringName:
	return _a_self_key

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	var metadata: _Instance_Metadata = _a_Instance.get_selected_metadata()
	var type: StringName = metadata.get_type()
	data[&"Instance_Key"] = metadata.get_key()
	data[&"Comp"] = &""
	if type == &"Object":
		data[&"Comp"] = _a_Comp.get_selected_metadata()
	data[&"Expression"] = _a_Expression_Value.get_text()
	data[&"Type"] = type
	
	return data

func load_data(p_data: Dictionary) -> void:
	var instance_key: StringName = p_data[&"Instance_Key"]
	var type: StringName = p_data[&"Type"]
	var expression: String = p_data[&"Expression"]
	var idx: int = 0
	if !instance_key.is_empty():
		if _a_self_key != instance_key:
			idx = _a_instance_idxs[instance_key]
	
	_a_Instance.select(idx)
	_selected_instance_changed()
	if type == &"Object":
		var comp: StringName = p_data[&"Comp"]
		idx = _a_comp_idxs[comp]
		_a_Comp.select(idx)
		_selected_comp_changed()
	_a_Expression_Value.set_text(expression)

func load_data_init() -> void:
	_a_Instance.select(0)
	_selected_instance_changed()
	_a_Expression_Value.set_text("")

func _on_Instance_item_selected(_p_idx: int) -> void:
	_selected_instance_changed()

func _on_Comp_item_selected(_p_idx: int) -> void:
	_selected_comp_changed()

func _on_Execute_pressed() -> void:
	var expression: String = _a_Expression_Value.get_text()
	_update_expression_error(expression)

func _on_Attributes_pressed() -> void:
	_a_attr_select.closed.connect(_on_Attr_Select_closed)
	_a_attr_select.method_selected.connect(_on_Attr_Select_method_selected)
	_a_attr_select.property_selected.connect(_on_Attr_Select_property_selected)
	_a_attr_select.update_list(_a_instance)
	_a_attr_select.open()

func _on_Attr_Select_closed() -> void:
	_a_attr_select.closed.disconnect(_on_Attr_Select_closed)
	_a_attr_select.method_selected.disconnect(_on_Attr_Select_method_selected)
	_a_attr_select.property_selected.disconnect(_on_Attr_Select_property_selected)

func _on_Attr_Select_property_selected(p_property: String) -> void:
	var text: String = _a_Expression_Value.get_text()
	var new_text: String = text + p_property
	_a_Expression_Value.set_text(new_text)

func _on_Attr_Select_method_selected(p_method: String) -> void:
	var text: String = _a_Expression_Value.get_text()
	var new_text: String = text + p_method + "()"
	_a_Expression_Value.set_text(new_text)

class _Instance_Metadata:
	var _a_key: StringName
	var _a_instance: Node
	var _a_type: StringName # Object/Curr_Scene/Singleton
	
	func _init(p_key: StringName, p_instance: Node, p_type: StringName) -> void:
		_a_key = p_key
		_a_instance = p_instance
		_a_type = p_type
	
	func get_key() -> StringName:
		return _a_key
	
	func get_instance() -> Node:
		return _a_instance
	
	func get_type() -> StringName:
		return _a_type
