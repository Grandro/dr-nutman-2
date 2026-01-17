extends CompBalloonsBase
class_name CompBalloonsStatic

func init(p_entity: Node) -> void:
	super(p_entity)
	for child: CompBalloonsContainerStatic in _a_Containers.get_children():
		var key: StringName = child.get_name()
		_a_containers[key] = child
	
	if _a_containers.is_empty():
		set_process(false)
