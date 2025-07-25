extends Static3DObject

@onready var _a_Book_38 = get_node("Books/Book_38")

func get_save_data():
	var data = super()
	data["Book_38"] = {}
	data["Book_38"]["Transform"] = _a_Book_38.get_transform()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Book_38.set_transform(p_data["Book_38"]["Transform"])
