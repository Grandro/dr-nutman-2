extends MapBase3D
class_name MapBrokoTown1

@onready var _a_Right_On_The_Nut: MiniGameBase = get_node("Mini_Games/Right_On_The_Nut")
@onready var _a_Squirrel_Fishing: MiniGameBase = get_node("Mini_Games/Squirrel_Fishing")

func _ready() -> void:
	super()
	_a_Right_On_The_Nut.closed.connect(_on_Mini_Game_closed)
	_a_Squirrel_Fishing.closed.connect(_on_Mini_Game_closed)

func open_right_on_the_nut() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: Player3D = global_si.get_player()
	player.comph().call_comp("Operate", &"disable")
	
	_a_Right_On_The_Nut.open()

func open_squirrel_fishing() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: Player3D = global_si.get_player()
	player.comph().call_comp("Operate", &"disable")
	
	_a_Squirrel_Fishing.open()

func load_data_init() -> void:
	super()
	
	# Assign random balloon color
	var colors: Array = [["eb2f2f", "Red"], ["2feb2f", "Green"], ["2f2feb", "Dark_Blue"],
						 ["eb9e1a", "Orange"], ["5f30a1", "Purple"], ["add8e6", "Light_Blue"],
				  		 ["ffc0cb", "Pink"]]
	colors.shuffle()
	
	var vp: Viewport = get_viewport()
	var children: Array[Node] = Global.get_nodes_in_group_vp(vp, "Child")
	for i: int in children.size():
		var child: Character3DObject = children[i]
		var color_hex: String = colors[i][0]
		var color_key: String = colors[i][1]
		child.comph().call_comp("Balloon_Quest", &"set_balloon_color_hex", [color_hex])
		child.comph().call_comp("Balloon_Quest", &"set_balloon_color_key", [color_key])

func _on_Mini_Game_closed() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: Player3D = global_si.get_player()
	player.comph().call_comp("Operate", &"enable")
