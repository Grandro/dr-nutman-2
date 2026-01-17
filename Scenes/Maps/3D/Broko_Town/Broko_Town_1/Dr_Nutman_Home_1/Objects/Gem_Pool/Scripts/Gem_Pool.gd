extends Static3DObject
class_name MapDrNutmanHome1ObjectGemPool

@onready var _a_Interactions: CompInteractions3D = get_node("Interactions")

func _ready() -> void:
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)

func _on_Interactions_interacted() -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(&"Gem_Pool_1", &"0")
	
	var global_si: Global = Global.get_singleton(self, "Global")
	global_si.restore_all_party_members_HP()
	global_si.restore_all_party_members_SP()
