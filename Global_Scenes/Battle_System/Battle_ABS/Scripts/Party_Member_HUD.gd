extends HBoxContainer

var _a_HUD_Entry_Scene = preload("res://Global_Scenes/Battle_System/Battle_ABS/HUD_Entry.tscn")

func _ready():
	hide()

func add_entry(p_instance, p_key):
	var data = Databases.get_data_entry("Party_Members", p_key)
	var global_si = Global.get_singleton(self, "Global")
	var instance = _a_HUD_Entry_Scene.instantiate()
	var stats = global_si.a_party_members[p_key]["Stats"]
	var max_HP = data["Stats"]["HP"]
	var max_SP = data["Stats"]["SP"]
	var bust_texture = load(Global.a_BATTLE_BUST_PATH % p_key)
	
	p_instance.set_hud_entry(instance)
	instance.set_data.call_deferred(stats, max_HP, max_SP, bust_texture)
	add_child(instance)

func clear_entries():
	for child in get_children():
		child.queue_free()
