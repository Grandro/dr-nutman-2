extends MarginContainer
class_name MainMenuSubMenuPartySelectionEntry

signal select_pressed()

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Anchor: Node2D = get_node("Anchor")
@onready var _a_Image_Anims: AnimationPlayer = get_node("Anchor/Image/Anims")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.focus_entered.connect(_on_Select_focus_entered)
	_a_Select.focus_exited.connect(_on_Select_focus_exited)

func grab_select_focus() -> void:
	_a_Select.grab_focus()

func _on_Select_pressed() -> void:
	select_pressed.emit()

func _on_Select_focus_entered() -> void:
	_a_Anchor.set_z_index(1)
	_a_Image_Anims.play(&"Zoom_In")

func _on_Select_focus_exited() -> void:
	_a_Anchor.set_z_index(0)
	_a_Image_Anims.play(&"Zoom_Out")
