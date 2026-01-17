@tool
@icon("res://Scenes/Custom_Containers/Anim_Box/Sprites/Node.png")
extends Container
class_name AnimBox

enum _a_ALIGN_MODE {BEGIN, CENTER, END}

@export var _e_separation: int = 0 : set = set_separation
@export var _e_align: _a_ALIGN_MODE = _a_ALIGN_MODE.BEGIN : set = set_align
@export var _e_anim_args: Dictionary = {
	&"Position": {
		&"Active": true,
		&"Duration": 0.3,
		&"Trans_Type": 2,
		&"Ease_Type": 2,
		&"Delay": 0.0
	},
	&"Size": {
		&"Active": false,
		&"Duration": 1.0,
		&"Trans_Type": 0,
		&"Ease_Type": 2,
		&"Delay": 0.0
	},
	&"Rotation": {
		&"Active": false,
		&"Duration": 1.0,
		&"Trans_Type": 0,
		&"Ease_Type": 2,
		&"Delay": 0.0
	},
	&"Scale": {
		&"Active": false,
		&"Duration": 1.0,
		&"Trans_Type": 0,
		&"Ease_Type": 2,
		&"Delay": 0.0
	}
}

var _a_vertical: bool = false
var _a_updated: Array[Node] = []
var _a_removed: Node = null

func _notification(p_what: int) -> void:
	match p_what:
		NOTIFICATION_SORT_CHILDREN: _resort()
		NOTIFICATION_THEME_CHANGED: update_minimum_size()

func add_child_(p_instance: Node, p_force_readable_name: bool = false, p_internal: int = 0) -> void:
	if _a_removed == p_instance:
		_a_updated.push_back(p_instance)
	_a_removed = null
	
	super.add_child(p_instance, p_force_readable_name, p_internal)

func remove_child_(p_instance: Node) -> void:
	if _a_updated.has(p_instance):
		_a_updated.erase(p_instance)
	_a_removed = p_instance
	
	super.remove_child(p_instance)

func _resort() -> void:
	var new_size: Vector2 = get_size()
	var first: bool = true
	var child_count: int = 0
	var stretch_min: float = 0.0
	var stretch_avail: float = 0.0
	var stretch_ratio_total: float = 0.0
	var min_size_cache: Dictionary[Node, _MinSizeCache] = {}
	
	for child: Node in get_children():
		if !(child is Control) || !child.is_visible_in_tree():
			continue
		if child.is_queued_for_deletion():
			continue
		if child.is_set_as_top_level():
			continue
		
		var size_: Vector2 = child.get_combined_minimum_size()
		var msc: _MinSizeCache = _MinSizeCache.new()
		if _a_vertical:
			stretch_min += size_.y
			msc.set_min_size(size_.y)
			msc.set_will_stretch(child.get_v_size_flags() & SIZE_EXPAND)
		else:
			stretch_min += size_.x
			msc.set_min_size(size_.x)
			msc.set_will_stretch(child.get_h_size_flags() & SIZE_EXPAND)
		
		if msc.get_will_stretch():
			stretch_avail += msc.get_min_size()
			stretch_ratio_total += child.get_stretch_ratio()
		
		msc.set_final_size(msc.get_min_size())
		min_size_cache[child] = msc
		child_count += 1
	
	if child_count == 0:
		return
	
	var stretch_max: float
	if _a_vertical:
		stretch_max = new_size.y - (child_count - 1) * _e_separation
	else:
		stretch_max = new_size.x - (child_count - 1) * _e_separation
	var stretch_diff: float = stretch_max - stretch_min
	stretch_diff = max(0.0, stretch_diff)
	
	stretch_avail += stretch_diff
	
	var has_stretched: bool = false
	while stretch_ratio_total > 0.0:
		has_stretched = true
		var refit_success: bool = true
		var error: float = 0.0
		
		for child: Node in get_children():
			if !(child is Control) || !child.is_visible_in_tree():
				continue
			if child.is_queued_for_deletion():
				continue
			if child.is_set_as_top_level():
				continue
			
			if !min_size_cache.has(child):
				push_error("!min_size_cache.has(child) is true")
				return
			
			var msc: _MinSizeCache = min_size_cache[child]
			if msc.get_will_stretch():
				var stretch_ratio: float = child.get_stretch_ratio()
				var final_pixel_size: float = stretch_avail * stretch_ratio / stretch_ratio_total
				error += final_pixel_size - int(final_pixel_size)
				if final_pixel_size < msc.get_min_size():
					msc.set_will_stretch(false)
					stretch_ratio_total -= stretch_ratio
					refit_success = false
					stretch_avail -= msc.get_min_size()
					msc.set_final_size(msc.get_min_size())
					break
				else:
					if error >= 1.0:
						msc.set_final_size(final_pixel_size + 1)
						error -= 1.0
					else:
						msc.set_final_size(final_pixel_size)
		
		if refit_success:
			break
	
	var ofs: float = 0.0
	if !has_stretched:
		match _e_align:
			_a_ALIGN_MODE.CENTER: ofs = stretch_diff / 2.0
			_a_ALIGN_MODE.END: ofs = stretch_diff
	
	first = true
	var idx: int = 0
	for child: Node in get_children():
		if !(child is Control) || !child.is_visible_in_tree():
			continue
		if child.is_queued_for_deletion():
			continue
		if child.is_set_as_top_level():
			continue
		
		var msc: _MinSizeCache = min_size_cache[child]
		if first:
			first = false
		else:
			ofs += _e_separation
		
		var from: float = ofs
		var to: float = ofs + msc.get_final_size()
		if msc.get_will_stretch() && idx == child_count - 1:
			if _a_vertical:
				to = new_size.y
			else:
				to = new_size.x
		
		var size_: float = to - from
		var rect: Rect2
		if _a_vertical:
			rect = Rect2(0.0, from, new_size.x, size_)
		else:
			rect = Rect2(from, 0.0, size_, new_size.y)
		
		var values: _ChildInRectValues = _get_fit_child_in_rect_values(child, rect)
		for property: StringName in _e_anim_args:
			if !_a_updated.has(child):
				_set_child_property(property, child, values)
				continue
			
			var args: Dictionary = _e_anim_args[property]
			var active: bool = args[&"Active"]
			if active:
				_interpolate_child_property(property, child, values)
			else:
				_set_child_property(property, child, values)
		
		if !_a_updated.has(child):
			_a_updated.push_back(child)
		
		ofs = to
		idx += 1

func _interpolate_child_property(p_property: StringName, p_child: Node, p_values: _ChildInRectValues) -> void:
	var args: Dictionary = _e_anim_args[p_property]
	var duration: float = args[&"Duration"]
	var trans_type: Tween.TransitionType = args[&"Trans_Type"]
	var ease_type: Tween.EaseType = args[&"Ease_Type"]
	var delay: float = args[&"Delay"]
	
	var tween: Tween = create_tween()
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	match p_property:
		&"Position": tween.tween_property(p_child, "position", p_values.get_position(), duration).set_delay(delay)
		&"Size": tween.tween_property(p_child, "size", p_values.get_size(), duration).set_delay(delay)
		&"Rotation": tween.tween_property(p_child, "rotation", p_values.get_rotation(), duration).set_delay(delay)
		&"Scale": tween.tween_property(p_child, "scale", p_values.get_scale(), duration).set_delay(delay)

func _set_child_property(p_property: StringName, p_child: Node, p_values: _ChildInRectValues) -> void:
	match p_property:
		&"Position": p_child.set_position(p_values.get_position())
		&"Size": p_child.set_size(p_values.get_size())
		&"Rotation": p_child.set_rotation(p_values.get_rotation())
		&"Scale": p_child.set_scale(p_values.get_scale())

func _get_minimum_size() -> Vector2:
	var minimum: Vector2 = Vector2.ZERO
	var first: bool = true
	for child: Node in get_children():
		if !(child is Control) || child.is_set_as_top_level():
			continue
		if !child.is_visible():
			continue
		
		var size_: Vector2 = child.get_combined_minimum_size()
		if _a_vertical:
			if size_.x > minimum.x:
				minimum.x = size_.x
			if first:
				minimum.y += size_.y
			else:
				minimum.y += size_.y + _e_separation
		else:
			if size_.y > minimum.y:
				minimum.y = size_.y
			if first:
				minimum.x += size_.x
			else:
				minimum.x += size_.x + _e_separation
		
		first = false
	
	return minimum

func _get_fit_child_in_rect_values(p_child: Control, p_rect: Rect2) -> _ChildInRectValues:
	var min_size: Vector2 = p_child.get_combined_minimum_size()
	var rect: Rect2 = p_rect
	
	var h_size_flags: int = p_child.get_h_size_flags()
	if !h_size_flags & SIZE_FILL:
		rect.size.x = min_size.x
		if h_size_flags & SIZE_SHRINK_END:
			rect.position.x += p_rect.size.x - min_size.x
		elif h_size_flags & SIZE_SHRINK_CENTER:
			rect.position.x += floor((p_rect.size.x - min_size.x) / 2)
	
	var y_size_flags: int = p_child.get_v_size_flags()
	if !y_size_flags & SIZE_FILL:
		rect.size.y = min_size.y
		if y_size_flags & SIZE_SHRINK_END:
			rect.position.y += p_rect.size.y - min_size.y
		elif y_size_flags & SIZE_SHRINK_CENTER:
			rect.position.y += floor((p_rect.size.y - min_size.y) / 2)
	
	for i: int in 4:
		p_child.set_anchor(i, ANCHOR_BEGIN)
	
	var values: _ChildInRectValues = _ChildInRectValues.new()
	values.set_position(rect.position)
	values.set_size(rect.size)
	
	return values

func set_separation(p_value: int) -> void:
	_e_separation = p_value
	update_minimum_size()
	_resort()

func set_align(p_value: _a_ALIGN_MODE) -> void:
	_e_align = p_value
	_resort()

func set_anim_position_active(p_active: bool) -> void:
	_e_anim_args[&"Position"][&"Active"] = p_active

func set_anim_position_duration(p_duration: float) -> void:
	_e_anim_args[&"Position"][&"Duration"] = p_duration

func set_anim_position_trans_type(p_trans_type: Tween.TransitionType) -> void:
	_e_anim_args[&"Position"][&"Trans_Type"] = p_trans_type

func set_anim_position_ease_type(p_ease_type: Tween.EaseType) -> void:
	_e_anim_args[&"Position"][&"Ease_Type"] = p_ease_type

func set_anim_position_delay(p_delay: float) -> void:
	_e_anim_args[&"Position"][&"Delay"] = p_delay

func set_anim_size_active(p_active: bool) -> void:
	_e_anim_args[&"Size"][&"Active"] = p_active

func set_anim_size_duration(p_duration: float) -> void:
	_e_anim_args[&"Size"][&"Duration"] = p_duration

func set_anim_size_trans_type(p_trans_type: Tween.TransitionType) -> void:
	_e_anim_args[&"Size"][&"Trans_Type"] = p_trans_type

func set_anim_size_ease_type(p_ease_type: Tween.EaseType) -> void:
	_e_anim_args[&"Size"][&"Ease_Type"] = p_ease_type

func set_anim_size_delay(p_delay: float) -> void:
	_e_anim_args[&"Size"][&"Delay"] = p_delay

func set_anim_rotation_active(p_active: bool) -> void:
	_e_anim_args[&"Rotation"][&"Active"] = p_active

func set_anim_rotation_duration(p_duration: float) -> void:
	_e_anim_args[&"Rotation"][&"Duration"] = p_duration

func set_anim_rotation_trans_type(p_trans_type: Tween.TransitionType) -> void:
	_e_anim_args[&"Rotation"][&"Trans_Type"] = p_trans_type

func set_anim_rotation_ease_type(p_ease_type: Tween.EaseType) -> void:
	_e_anim_args[&"Rotation"][&"Ease_Type"] = p_ease_type

func set_anim_rotation_delay(p_delay: float) -> void:
	_e_anim_args[&"Rotation"][&"Delay"] = p_delay

func set_anim_scale_active(p_active: bool) -> void:
	_e_anim_args[&"Scale"][&"Active"] = p_active

func set_anim_scale_duration(p_duration: float) -> void:
	_e_anim_args[&"Scale"][&"Duration"] = p_duration

func set_anim_scale_trans_type(p_trans_type: Tween.TransitionType) -> void:
	_e_anim_args[&"Scale"][&"Trans_Type"] = p_trans_type

func set_anim_scale_ease_type(p_ease_type: Tween.EaseType) -> void:
	_e_anim_args[&"Scale"][&"Ease_Type"] = p_ease_type

func set_anim_scale_delay(p_delay: float) -> void:
	_e_anim_args[&"Scale"][&"Delay"] = p_delay

class _MinSizeCache:
	var _a_min_size: float
	var _a_will_stretch: bool
	var _a_final_size: float
	
	func set_min_size(p_min_size: float) -> void:
		_a_min_size = p_min_size
	
	func get_min_size() -> float:
		return _a_min_size
	
	func set_will_stretch(p_will_stretch: bool) -> void:
		_a_will_stretch = p_will_stretch
	
	func get_will_stretch() -> bool:
		return _a_will_stretch
	
	func set_final_size(p_final_size: float) -> void:
		_a_final_size = p_final_size
	
	func get_final_size() -> float:
		return _a_final_size

class _ChildInRectValues:
	var _a_position: Vector2
	var _a_size: Vector2
	var _a_rotation: float = 0.0
	var _a_scale: Vector2 = Vector2.ONE
	
	func set_position(p_position: Vector2) -> void:
		_a_position = p_position
	
	func get_position() -> Vector2:
		return _a_position
	
	func set_size(p_size: Vector2) -> void:
		_a_size = p_size
	
	func get_size() -> Vector2:
		return _a_size
	
	func get_rotation() -> float:
		return _a_rotation
	
	func get_scale() -> Vector2:
		return _a_scale
