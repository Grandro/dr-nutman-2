extends FWGlobal

@onready var _a_Tutato: FWNode2DObject = get_node("Canvas/Tutato")

func start_game() -> void:
	super()
	
	# GAIN ITEMS
	#change_item_amount("Cookie", 67)
	#change_item_amount("Handful_Peanuts_Cracked", 18)
	#change_item_amount("Handful_Peanuts_Uncracked", 18)
	#change_item_amount("Party_Hat_1", 18)
	#change_item_amount("Disposable_Glove", 1)
	#change_item_amount("Citrin_Shield", 1)
	# ---------------
	
	# ACTIVATE PARTY MEMBERS
	activate_party_member(&"Dr_Nutman")
	#activate_party_member("Buffin_Assistant_1")
	# ----------------------

func get_tutato_explain(p_key: StringName) -> ObjectTutatoCompExplainBase2D:
	return _a_Tutato.comph().get_comp(p_key)
