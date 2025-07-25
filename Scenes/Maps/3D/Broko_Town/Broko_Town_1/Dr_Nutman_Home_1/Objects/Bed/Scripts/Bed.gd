extends Static3DObject

@onready var _a_Pillow = get_node("Model/Pillow")
@onready var _a_Blanket = get_node("Model/Blanket")

func _ready():
	super()
	Global_Data.fav_color_changed.connect(_on_Global_Data_fav_color_changed)
	
	var fav_color = Global_Data.get_fav_color()
	var pillow_surface_mat = _a_Pillow.get_mesh().surface_get_material(0)
	var blanket_surface_mat = _a_Blanket.get_mesh().surface_get_material(0)
	pillow_surface_mat.set_albedo(fav_color)
	blanket_surface_mat.set_albedo(fav_color)

func _on_Global_Data_fav_color_changed(p_color):
	var pillow_surface_mat = _a_Pillow.get_mesh().surface_get_material(0)
	var blanket_surface_mat = _a_Blanket.get_mesh().surface_get_material(0)
	pillow_surface_mat.set_albedo(p_color)
	blanket_surface_mat.set_albedo(p_color)
