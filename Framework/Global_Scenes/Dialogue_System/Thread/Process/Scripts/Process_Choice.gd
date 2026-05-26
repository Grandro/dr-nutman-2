extends FWDialogueSystemThreadProcessBase
class_name FWDialogueSystemThreadProcessChoice

@onready var _a_Choice_1: MarginContainer = get_node("Control/Choice/Margin/VBox/HBox_1/Choice_1/Select")
@onready var _a_Choice_2: MarginContainer = get_node("Control/Choice/Margin/VBox/HBox_1/Choice_2/Select")
@onready var _a_Choice_3: MarginContainer = get_node("Control/Choice/Margin/VBox/HBox_2/Choice_3/Select")
@onready var _a_Choice_4: MarginContainer = get_node("Control/Choice/Margin/VBox/HBox_2/Choice_4/Select")
@onready var _a_Name: NinePatchRect = get_node("Control/Name")
@onready var _a_Name_Text: RichTextLabel = get_node("Control/Name/Margin/Text")
@onready var _a_Anims: AnimationPlayer = get_node("Control/Anims")

var _a_choices: Array[MarginContainer] = [] # Choice Select instances

func _ready() -> void:
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	_a_choices = [_a_Choice_1, _a_Choice_2, _a_Choice_3, _a_Choice_4]
	_set_data_choice()
	
	if _a_fade_in:
		_a_Anims.play(&"Fade_In")
	else:
		_a_Anims.play(&"Faded_In")

func _set_data_choice() -> void:
	var data: Dictionary = _a_args[&"Data"][&"Choice"]
	var choices: Array[Dictionary] = data[&"Entries"]
	for i: int in choices.size():
		var args: Dictionary = choices[i]
		var instance: MarginContainer = _a_choices[i]
		var loc_id: StringName = args[&"Loc_ID"]
		var value: Variant = args[&"Value"]
		instance.pressed.connect(_on_Choice_pressed.bind(value))
		instance.set_text(tr(loc_id))
	
	var name_id: StringName = data[&"Name_ID"]
	if name_id != &"":
		_a_Name_Text.set_text(tr(name_id))
	else:
		_a_Name.hide()

func _on_anim_finished(p_anim: StringName) -> void:
	if p_anim == &"Fade_Out":
		await get_tree().process_frame
		completed.emit()
		queue_free()

func _on_Choice_pressed(p_value: Variant) -> void:
	choice_selected.emit(p_value)
	_a_Anims.play(&"Fade_Out")
