extends FWStatic3DObject
class_name MapDrNutmanHome1ObjectGemPool

@onready var _a_Interactions: FWCompInteractions3D = get_node("Interactions")

func _ready() -> void:
	super()
	_a_Interactions.interacted_empty.connect(_on_Interactions_interacted_empty)

func _on_Interactions_interacted_empty() -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var global_si: Global = Global.get_singleton(self, "Global")
	cutscene_system_si.cutscene(&"Gem_Pool_1", &"0")
	global_si.restore_all_party_members_HP()
	global_si.restore_all_party_members_SP()
