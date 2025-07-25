extends VBoxContainer

signal static_color_selected(p_color, p_is_fav_color)

const _a_TYPES = ["Static"]

@onready var _a_Type = get_node("Type/Options")
@onready var _a_Static = get_node("Static")

func _ready():
	_a_Type.item_selected.connect(_on_Type_item_selected)
	_a_Static.color_selected.connect(_on_Static_color_selected)
	
	_create_type_options()
	
	hide()

func open(p_save_data):
	var static_data = {}
	var type_idx = 0
	var open_ = true
	if !p_save_data.is_empty():
		static_data = p_save_data["Static"]
		type_idx = p_save_data["Type_Idx"]
		open_ = p_save_data["Open"]
	
	_a_Static.load_save_data(static_data)
	_a_Type.select(type_idx)
	_selected_type_changed()
	set_visible(open_)

func _create_type_options():
	for i in _a_TYPES.size():
		var type = _a_TYPES[i]
		var text = tr(type.to_upper())
		_a_Type.add_item(text)

func _selected_type_changed():
	var idx = _a_Type.get_selected_id()
	var child = get_child(idx + 1)
	child.show()

func get_save_data():
	var data = {}
	data["Static"] = _a_Static.get_save_data()
	data["Type_Idx"] = _a_Type.get_selected_id()
	data["Open"] = is_visible()
	
	return data

func _on_Type_item_selected(_p_idx):
	_selected_type_changed()

func _on_Static_color_selected(p_color, p_is_fav_color):
	static_color_selected.emit(p_color, p_is_fav_color)
