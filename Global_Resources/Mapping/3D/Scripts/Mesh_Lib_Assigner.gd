@tool
extends Node3D
class_name MeshLibAssigner

@export_dir var _e_dir: String = ""
@export_category("Debug")
@export_tool_button("Assign") var _e_assign_button: Callable = _assign_meshes
@export_tool_button("Rename") var _e_rename_button: Callable = _rename_mesh_instances

func _assign_meshes() -> void:
	for child: Node3D in get_tree().get_nodes_in_group("Assign"):
		var mesh_instance: MeshInstance3D = child.get_child(0)
		var mesh_name: StringName = mesh_instance.get_name()
		var mesh_path: String = "%s/Mesh_Lib_%s.res" % [_e_dir, mesh_name]
		var mesh: Mesh = load(mesh_path)
		mesh_instance.set_mesh(mesh)

func _rename_mesh_instances() -> void:
	for child: Node3D in get_children():
		var child_name: StringName = child.get_name()
		var mesh_instance: MeshInstance3D = child.get_child(0)
		mesh_instance.set_name(child_name)
