extends VBoxContainer
class_name SVResultPartyMemberEntryBase

@onready var _a_Lvl: Label = get_node("Panel/VBox/Lvl/Value")
@onready var _a_Exp_Text: Label = get_node("Panel/VBox/Exp/Text/HBox/Value")
@onready var _a_Exp_Progress: ProgressBar = get_node("Panel/VBox/Exp/Progress")

var _a_pm_args: PartyMemberData = null
var _a_progress: Dictionary[StringName, Variant] = {} # Progress dic for Party_Member

func open(p_pm_args: PartyMemberData, p_progress: Dictionary[StringName, Variant], p_exp: int) -> void:
	_a_pm_args = p_pm_args
	_a_progress = p_progress
	_update_lvl()
	_update_curr_exp()
	_set_new_exp(p_exp)
	
	_tween_exp_progress(p_exp)

func _tween_exp_progress(p_exp: int) -> void:
	var curr_exp: int = _a_progress[&"Exp"]
	var curr_lvl: int = _a_progress[&"Lvl"]
	var next_lvl_exp: int = _a_pm_args.get_exp_till_next_lvl(curr_lvl + 1)
	var new_exp: int = curr_exp + p_exp
	var remaining_exp: int = max(0, new_exp - next_lvl_exp)
	var progress_value: int = min(new_exp, next_lvl_exp)
	var tween: Tween = create_tween()
	tween.finished.connect(_on_Exp_Progress_Tween_finished.bind(remaining_exp))
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(_a_Exp_Progress, "value", progress_value, 1.0).from_current()
	
	_a_progress[&"Exp"] = progress_value

func _update_lvl() -> void:
	var lvl: int = _a_progress[&"Lvl"]
	_a_Lvl.set_text(str(lvl))

func _update_curr_exp() -> void:
	var curr_exp: int = _a_progress[&"Exp"]
	var curr_lvl: int = _a_progress[&"Lvl"]
	var next_lvl_exp: int = _a_pm_args.get_exp_till_next_lvl(curr_lvl + 1)
	_a_Exp_Progress.set_max(next_lvl_exp)
	_a_Exp_Progress.set_value(curr_exp)

func _set_new_exp(p_new_exp: int) -> void:
	_a_Exp_Text.set_text(str(p_new_exp))

func _on_Exp_Progress_Tween_finished(p_remaining_exp: int) -> void:
	if p_remaining_exp > 0:
		_a_progress[&"Lvl"] += 1
		_a_progress[&"Exp"] = 0
		_update_lvl()
		_tween_exp_progress(p_remaining_exp)
