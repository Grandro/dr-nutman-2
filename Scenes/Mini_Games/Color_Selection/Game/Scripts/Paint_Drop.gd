extends RigidBody2D

@export var _e_on_floor_physics_mat: PhysicsMaterial
@export var _e_in_air_physics_mat: PhysicsMaterial

@onready var _a_Audio_Bump = get_node("Audio_Bump")
@onready var _a_Audio_Bump_CD = get_node("Audio_Bump_CD")

var _a_color = Color.WHITE
var _a_on_floor = false # Check if is on floor -> mix color
var _a_neighbors = [self] # Paint_Drop neighbors

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func set_color(p_color):
	_a_color = p_color

func get_color():
	return _a_color

func set_on_floor(p_on_floor):
	if p_on_floor:
		set_physics_material_override(_e_on_floor_physics_mat)
	else:
		set_physics_material_override(_e_in_air_physics_mat)
	
	_a_on_floor = p_on_floor

func is_on_floor():
	return _a_on_floor

func get_neighbors(p_prev = []):
	var all_neighbors = []
	for neighbor in _a_neighbors:
		if !p_prev.has(neighbor):
			all_neighbors.append(neighbor)
	
	for neighbor in all_neighbors:
		var neighbors = neighbor.get_neighbors(all_neighbors + p_prev)
		all_neighbors.append_array(neighbors)
	
	return all_neighbors

func _on_body_entered(p_instance):
	if p_instance.is_in_group("Paint_Drop"):
		_a_neighbors.push_back(p_instance)
		
		if _a_Audio_Bump_CD.get_time_left() == 0.0:
			_a_Audio_Bump.play()
			_a_Audio_Bump_CD.start()
		
		if p_instance.get_color() == _a_color:
			return
		
		var all_neighbors = get_neighbors()
		var final_color = Vector3.ZERO
		for neighbor in all_neighbors:
			var color = neighbor.get_color()
			final_color.x += color.r
			final_color.y += color.g
			final_color.z += color.b
		final_color /= all_neighbors.size()
		
		for neighbor in all_neighbors:
			var color = Color(final_color.x, final_color.y, final_color.z)
			neighbor.set_color(color)
			neighbor.set_modulate(color)

func _on_body_exited(p_instance):
	if p_instance.is_in_group("Paint_Drop"):
		_a_neighbors.erase(p_instance)
