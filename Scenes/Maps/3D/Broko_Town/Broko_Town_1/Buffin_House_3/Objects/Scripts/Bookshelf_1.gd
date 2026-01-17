extends Static3DObject
class_name MapBuffinHouse3ObjectBookshelf1

@onready var _a_Book_38: Node3D = get_node("Books/Book_38")

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Book_38"] = {}
	data[&"Book_38"][&"Transform"] = _a_Book_38.get_transform()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Book_38.set_transform(p_data[&"Book_38"][&"Transform"])
