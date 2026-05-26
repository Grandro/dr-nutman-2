extends RigidBody3D
class_name FWRigidBody3DObject

var _a_comph: FWCompHandler = FWCompHandler.new(self)

func _ready() -> void:
	_a_comph.register_comps()

func _integrate_forces(p_state: PhysicsDirectBodyState3D) -> void:
	if _a_comph.has_comp("Movement"):
		_a_comph.call_comp("Movement", &"integrate_forces", [p_state])

func comph() -> FWCompHandler:
	return _a_comph

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Visible"] = is_visible()
	data[&"Transform"] = get_transform()
	data[&"Freeze"] = is_freeze_enabled()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_visible(p_data[&"Visible"])
	set_transform(p_data[&"Transform"])
	set_freeze_enabled(p_data[&"Freeze"])

func load_data_init() -> void:
	pass
