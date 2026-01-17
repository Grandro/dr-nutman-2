extends HBoxContainer
class_name ABSPartyMemberHUD

var _a_HUD_Entry_Scene: PackedScene = preload("res://Global_Scenes/Battle_System/ABS_Battle/HUD_Entry.tscn")

func _ready():
	hide()

func add_entry(p_instance, p_key: StringName) -> void:
	var data: PartyMemberData = Databases.get_data_entry(&"Party_Members", p_key)
	var global_si: Global = Global.get_singleton(self, "Global")
	var instance = _a_HUD_Entry_Scene.instantiate()
	var stats = global_si.a_party_members[p_key]["Stats"]
	var max_HP: int = data.get_stats().get_HP()
	var max_SP: int = data.get_stats().get_SP()
	var bust_texture: Texture2D = load(Global.a_BATTLE_BUST_PATH % p_key)
	
	p_instance.set_hud_entry(instance)
	instance.set_data.call_deferred(stats, max_HP, max_SP, bust_texture)
	add_child(instance)

func clear_entries() -> void:
	for child in get_children():
		child.queue_free()
