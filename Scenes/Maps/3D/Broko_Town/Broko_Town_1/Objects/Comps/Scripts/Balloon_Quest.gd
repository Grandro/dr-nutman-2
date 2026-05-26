extends Node
class_name CompBalloonQuest

const _a_COLOR_LOC_ID: String = "COLOR_%s"

var _a_entity_comph: FWCompHandler

var _a_balloon_color_hex: String
var _a_balloon_color_key: String

func init(p_entities: Array[Node]) -> void:
	_a_entity_comph = p_entities[-1].comph()

func change_balloon_item_amount(p_amount: int) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var item_key: StringName = "Balloon_%s" % _a_balloon_color_key
	global_si.change_item_amount(item_key, p_amount)

func change_player_get_balloon_visuals() -> void:
	# 1) Give Player Balloons Comp colored balloon
	# 2) Delete Balloon_Cart_1 Balloons Comp balloon
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: FWPlayer3D = global_si.get_object(&"Player")
	var balloon_cart: FWStatic3DObject = global_si.get_object(&"Balloon_Cart_1")
	var balloon_color: Color = get_balloon_color()
	player.comph().call_comp("Balloons", &"instantiate_container", [&"1", balloon_color])
	balloon_cart.comph().call_comp("Balloons", &"delete_container", [_a_balloon_color_key])

func change_self_get_balloon_visuals() -> void:
	# 1) Give Self Balloons Comp colored ballon
	var balloon_color: Color = get_balloon_color()
	_a_entity_comph.call_comp("Balloons", &"instantiate_container", [&"1", balloon_color])

func set_balloon_color_hex(p_balloon_color_hex: String) -> void:
	_a_balloon_color_hex = p_balloon_color_hex

func get_balloon_color() -> Color:
	return Color(_a_balloon_color_hex)

func set_balloon_color_key(p_balloon_color_key: String) -> void:
	_a_balloon_color_key = p_balloon_color_key

func get_balloon_color_text() -> String:
	var base_text: String = "[color=%s][outline_size=4]%s[/outline_size][/color]"
	var color_text: String = tr(_a_COLOR_LOC_ID % _a_balloon_color_key.to_upper())
	var text: String = base_text % [_a_balloon_color_hex, color_text]
	
	return text

func get_balloon_img_text() -> String:
	var base_text: String = "[img]res://Global_Resources/Sprites/Items/Balloon_%s.png[/img]"
	var text: String = base_text % _a_balloon_color_key
	
	return text

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Balloon_Color_Hex"] = _a_balloon_color_hex
	data[&"Balloon_Color_Key"] = _a_balloon_color_key
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_balloon_color_hex(p_data[&"Balloon_Color_Hex"])
	set_balloon_color_key(p_data[&"Balloon_Color_Key"])

func load_data_init() -> void:
	pass
