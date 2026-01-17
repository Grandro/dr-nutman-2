extends Node

#signal flipped()

#var _a_flipped: bool = false
#var _a_disabled: bool = false
#
#func flip_on() -> void:
	#set_state(&"Flip_On")
	#update_anim()
	#set_allowed(false)
#
#func flip_off() -> void:
	#set_state(&"Flip_Off")
	#update_anim()
	#set_allowed(false)
#
#func interaction(_p_area) -> void:
	#if _a_disabled:
		#return
	#
	#if _a_flipped:
		#flip_off()
	#else:
		#flip_on()
#
#func set_disabled(p_disabled: bool) -> void:
	#_a_disabled = p_disabled
#
#func _on_anim_finished(p_name: StringName) -> void:
	#if "Flip_On_" in p_name:
		#set_state(&"Flipped_On")
		#_a_flipped = true
	#elif "Flip_Off_" in p_name:
		#set_state(&"Flipped_Off")
		#_a_flipped = false
	#else:
		#super(p_name)
		#return
	#
	#set_allowed(true)
	#flipped.emit()
	#
	#super(p_name)
