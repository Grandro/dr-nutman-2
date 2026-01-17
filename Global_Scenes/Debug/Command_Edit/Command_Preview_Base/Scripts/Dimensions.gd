extends ExtensionBase
class_name DebugCommandEditPreviewBaseDimensions

var _a_grid_step: Node
var _a_grid_offset: Node

func _init(p_entity) -> void:
	super(p_entity)
	_a_grid_step = _a_entity.get_grid_step_instance()
	_a_grid_offset = _a_entity.get_grid_offset_instance()
	
	_a_grid_step.x_value_changed.connect(_on_Grid_Step_x_value_changed)
	_a_grid_step.y_value_changed.connect(_on_Grid_Step_y_value_changed)
	_a_grid_offset.x_value_changed.connect(_on_Grid_Offset_value_changed)
	_a_grid_offset.y_value_changed.connect(_on_Grid_Offset_value_changed)

func handle_free_camera_pan(_p_relative: Vector2) -> void:
	pass

func handle_free_camera_zoom_in(_p_factor: float) -> void:
	pass

func handle_free_camera_zoom_out(_p_factor: float) -> void:
	pass

func get_grid_length(_p_grid_size) -> int:
	return -1

func get_global_mouse_pos() -> Variant:
	return null

func _on_Grid_Step_x_value_changed(p_value: float) -> void:
	_a_grid_offset.set_x_max(p_value)
	_a_entity.update_grid()

func _on_Grid_Step_y_value_changed(p_value: float) -> void:
	_a_grid_offset.set_y_max(p_value)
	_a_entity.update_grid()

func _on_Grid_Offset_value_changed(_p_value: float) -> void:
	_a_entity.update_grid()
