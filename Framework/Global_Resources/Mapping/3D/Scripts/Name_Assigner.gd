@tool
extends Node
class_name FWNameAssigner

@export_tool_button("Reassign Names") var _e_button: Callable = _on_button_pressed
@export var _e_prefix: String = ""

func _on_button_pressed() -> void:
	for i: int in get_child_count():
		var child: Node = get_child(i)
		var child_name: StringName = _e_prefix + str(i + 1)
		child.set_name(child_name)
