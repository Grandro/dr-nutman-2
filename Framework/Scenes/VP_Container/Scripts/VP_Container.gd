extends SubViewportContainer
class_name FWVPContainer

@onready var _a_VP: FWVP = get_node("VP")

func _ready() -> void:
	pass
	#var root = get_tree().get_root()
	#visibility_changed.connect(_on_visibility_changed)
	#root.size_changed.connect(_on_root_size_changed)

func get_VP() -> FWVP:
	return _a_VP

func _on_visibility_changed() -> void:
	pass
	#if is_visible_in_tree() && _a_VP.get_resize():
	#	_a_VP.resize()

func _on_root_size_changed() -> void:
	pass
	#if is_visible_in_tree() && _a_VP.get_resize():
	#	_a_VP.resize()
