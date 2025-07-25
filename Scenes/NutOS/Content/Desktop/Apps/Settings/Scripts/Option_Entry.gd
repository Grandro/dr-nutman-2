extends MarginContainer

signal selected()

@onready var _a_Select = get_node("Select")
@onready var _a_Icon = get_node("Margin/HBox/Icon")
@onready var _a_Heading = get_node("Margin/HBox/VBox/Heading")
@onready var _a_Desc = get_node("Margin/HBox/VBox/Desc")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)

func set_icon(p_texture):
	_a_Icon.set_texture(p_texture)

func set_heading(p_text):
	_a_Heading.set_text(p_text)

func set_desc(p_text):
	_a_Desc.set_text(p_text)

func _on_Select_pressed():
	selected.emit()
