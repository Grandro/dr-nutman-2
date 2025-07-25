extends "res://Scenes/Object_Map_Base/Scripts/Object_Map.gd"

signal flipped()

var _a_flipped = false
var _a_disabled = false

func flip_on():
	set_state("Flip_On")
	update_anim()
	set_interaction_allowed(false)

func flip_off():
	set_state("Flip_Off")
	update_anim()
	set_interaction_allowed(false)

func interaction(_p_area):
	if _a_disabled:
		return
	
	if _a_flipped:
		flip_off()
	else:
		flip_on()

func set_disabled(p_disabled):
	_a_disabled = p_disabled

func _on_anim_finished(p_name):
	if "Flip_On_" in p_name:
		set_state("Flipped_On")
		_a_flipped = true
	elif "Flip_Off_" in p_name:
		set_state("Flipped_Off")
		_a_flipped = false
	else:
		super(p_name)
		return
	
	set_interaction_allowed(true)
	flipped.emit()
	
	super(p_name)
