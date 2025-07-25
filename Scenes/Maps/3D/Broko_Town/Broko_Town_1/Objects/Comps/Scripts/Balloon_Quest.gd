extends Node

const _a_COLOR_LOC_ID = "COLOR_%s"

var _a_entity_comph: CompHandler = null

var _a_balloon_color_hex = ""
var _a_balloon_color_key = ""

func init(p_entity):
	_a_entity_comph = p_entity.comph()

func change_balloon_item_amount(p_amount):
	var global_si = Global.get_singleton(self, "Global")
	var item_key = "Balloon_%s" % _a_balloon_color_key
	global_si.change_item_amount(item_key, p_amount)

func change_player_get_balloon_visuals():
	# 1) Give Player Balloons Comp colored balloon
	# 2) Delete Balloon_Cart_1 Balloons Comp balloon
	var global_si = Global.get_singleton(self, "Global")
	var player = global_si.get_object("Player")
	var balloon_cart = global_si.get_object("Balloon_Cart_1")
	var balloon_color = get_balloon_color()
	player.comph().call_comp("Balloons", "instantiate_container", ["1", balloon_color])
	balloon_cart.comph().call_comp("Balloons", "delete_container", [_a_balloon_color_key])

func change_self_get_balloon_visuals():
	# 1) Give Self Balloons Comp colored ballon
	var balloon_color = get_balloon_color()
	_a_entity_comph.call_comp("Balloons", "instantiate_container", ["1", balloon_color])

func set_balloon_color_hex(p_balloon_color_hex):
	_a_balloon_color_hex = p_balloon_color_hex

func get_balloon_color():
	return Color(_a_balloon_color_hex)

func set_balloon_color_key(p_balloon_color_key):
	_a_balloon_color_key = p_balloon_color_key

func get_balloon_color_text():
	var base_text = "[color=%s][outline_size=4]%s[/outline_size][/color]"
	var color_text = tr(_a_COLOR_LOC_ID % _a_balloon_color_key.to_upper())
	var text = base_text % [_a_balloon_color_hex, color_text]
	
	return text

func get_save_data():
	var data = {}
	data["Balloon_Color_Hex"] = _a_balloon_color_hex
	data["Balloon_Color_Key"] = _a_balloon_color_key
	
	return data

func load_data(p_data):
	set_balloon_color_hex(p_data["Balloon_Color_Hex"])
	set_balloon_color_key(p_data["Balloon_Color_Key"])

func load_data_init():
	pass
