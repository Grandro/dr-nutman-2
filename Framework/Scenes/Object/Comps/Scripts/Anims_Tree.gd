extends FWCompAnims
class_name FWCompAnimsTree

@onready var _a_Tree: AnimationTree = get_node("Tree")

#var _a_root_node_blend_tree: AnimationNodeBlendTree

func _ready() -> void:
	_a_Tree.animation_finished.connect(_on_Tree_animation_finished)
	#_a_root_node_blend_tree = _a_Tree.get_tree_root()

func play_anim(p_name: StringName, p_speed: float = 1.0, p_backwards: bool = false) -> void:
	#var blend_tree: AnimationNodeBlendTree = _a_root_node_blend_tree.get_node(p_name)
	#var anim_node: AnimationNodeAnimation = blend_tree.get_node(p_name)
	if p_backwards:
		#anim_node.set_play_mode(AnimationNodeAnimation.PLAY_MODE_BACKWARD)
		_a_Tree.set(&"parameters/Speed/Scale", -p_speed)
	else:
		#anim_node.set_play_mode(AnimationNodeAnimation.PLAY_MODE_FORWARD)
		_a_Tree.set(&"parameters/Speed/Scale", p_speed)
	_a_Tree.set(&"parameters/Trans/transition_request", str(p_name))
	anim_played.emit(p_name)

func seek_anim(p_seconds: float, p_update: bool = false) -> void:
	_a_Tree.set(&"parameters/Seek/seek_request", p_seconds)
	anim_seeked.emit(p_seconds, p_update)

func stop_anim(p_keep_state: bool = false) -> void:
	_a_Tree.set(&"parameters/Speed/Scale", 0.0)
	if !p_keep_state:
		_a_Tree.set(&"parameters/Seek/seek_request", 0.0)
	anim_stopped.emit(p_keep_state)

func set_param(p_name: StringName, p_value: Variant) -> void:
	_a_Tree.set(p_name, p_value)

func _on_Tree_animation_finished(p_name: StringName) -> void:
	animation_finished.emit(p_name)
