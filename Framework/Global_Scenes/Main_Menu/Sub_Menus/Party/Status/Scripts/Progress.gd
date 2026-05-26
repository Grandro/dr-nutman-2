extends VBoxContainer
class_name MainMenuSubMenuPartyStatusProgress

@onready var a_Exp: Label = get_node("Exp/Value")
@onready var a_Next_Lvl: Label = get_node("Next_Lvl/Value")

func open(p_pm_key: StringName, p_progress: Dictionary) -> void:
	var pm_args: PartyMemberData = Databases.get_data_entry(&"Party_Members", p_pm_key)
	var lvl: int = p_progress[&"Lvl"]
	var exp_: int = p_progress[&"Exp"]
	var next_lvl_exp: int = pm_args.get_exp_till_next_lvl(lvl + 1)
	var next_lvl: int = next_lvl_exp - exp_
	a_Exp.set_text(str(exp_))
	a_Next_Lvl.set_text(str(next_lvl))
