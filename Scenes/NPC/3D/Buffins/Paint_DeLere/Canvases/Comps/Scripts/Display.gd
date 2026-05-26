extends FWCompDisplay3D
class_name CompPaintDeLereCanvasDisplay

const _a_PICTURE_PATH: String = "res://Scenes/NPC/3D/Buffins/Paint_DeLere/Canvases/Sprites/Pictures/%s.png"

@onready var _a_Picture: Sprite3D = get_node("Picture")

var _a_tween: Tween = null
var _a_to: float = -1.0
var _a_percent_duration: float = -1.0

func start_tween_picture_progress(p_from: float, p_to: float, p_percent_duration: float) -> void:
	_a_to = p_to
	_a_percent_duration = p_percent_duration
	
	stop_tween_picture_progress()
	var mat: Material = _a_Picture.get_material_override()
	var duration: float = (p_to - p_from) * 100.0 * p_percent_duration
	_a_tween = create_tween()
	_a_tween.tween_property(mat, "shader_parameter/progress", p_to, duration).from(p_from)

func stop_tween_picture_progress() -> void:
	if _a_tween != null:
		_a_tween.kill()
		_a_tween = null

func set_picture_texture(p_texture: Texture2D) -> void:
	var mat: Material = _a_Picture.get_material_override()
	mat.set_shader_parameter(&"texture_albedo", p_texture)

func set_picture_texture_name(p_name: String) -> void:
	var mat: Material = _a_Picture.get_material_override()
	var path: String = _a_PICTURE_PATH % p_name
	var texture_: Texture2D = load(path)
	mat.set_shader_parameter(&"texture_albedo", texture_)

func set_picture_progress(p_progress: float) -> void:
	var mat: Material = _a_Picture.get_material_override()
	mat.set_shader_parameter(&"progress", p_progress)

func get_picture_progress() -> float:
	var mat: Material = _a_Picture.get_material_override()
	return mat.get_shader_parameter(&"progress")

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	var mat: Material = _a_Picture.get_material_override()
	data[&"Picture"] = {}
	data[&"Picture"][&"Material"] = Data_Parser.parse_object(mat)
	
	var active: bool = false
	if _a_tween != null:
		active = _a_tween.is_running()
	data[&"Picture"][&"Tween"] = {}
	data[&"Picture"][&"Tween"][&"Active"] = active
	data[&"Picture"][&"Tween"][&"To"] = _a_to
	data[&"Picture"][&"Tween"][&"Percent_Duration"] = _a_percent_duration
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	var mat: Material = Data_Parser.unparse_object(p_data[&"Picture"][&"Material"])
	_a_Picture.set_material_override(mat)
	
	var active: bool = p_data[&"Picture"][&"Tween"][&"Active"]
	if active:
		var from: float = get_picture_progress()
		var to: float = p_data[&"Picture"][&"Tween"][&"To"]
		var percent_duration: float = p_data[&"Picture"][&"Tween"][&"Percent_Duration"]
		start_tween_picture_progress(from, to, percent_duration)
