extends SVPartyMemberCompShieldBarBase

func process_effect(p_entity: SVPartyMember) -> void:
	p_entity.comph().call_comp("Status", &"add_status", [&"Empowered_Attack", 1])
