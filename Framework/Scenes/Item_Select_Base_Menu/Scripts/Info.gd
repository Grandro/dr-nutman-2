extends PanelContainer
class_name FWItemSelectInfo

signal use_pressed()
signal select_pressed()

@export var _e_can_use: bool = true
@export var _e_select_mode: bool = false

@onready var _a_VBox: VBoxContainer = get_node("Margin/VBox")
@onready var _a_Name: Label = get_node("Margin/VBox/Name")
@onready var _a_Image: TextureRect = get_node("Margin/VBox/Image")
@onready var _a_Desc: RichTextLabel = get_node("Margin/VBox/VBox/Desc")
@onready var _a_Stats: HBoxContainer = get_node("Margin/VBox/VBox/Stats")
@onready var _a_Stats_HP: Label = get_node("Margin/VBox/VBox/Stats/Left/HP/Value")
@onready var _a_Stats_SP: Label = get_node("Margin/VBox/VBox/Stats/Left/SP/Value")
@onready var _a_Stats_ATK: Label = get_node("Margin/VBox/VBox/Stats/Left/ATK/Value")
@onready var _a_Stats_MAG: Label = get_node("Margin/VBox/VBox/Stats/Middle/MAG/Value")
@onready var _a_Stats_DEF: Label = get_node("Margin/VBox/VBox/Stats/Middle/DEF/Value")
@onready var _a_Stats_SPEED: Label = get_node("Margin/VBox/VBox/Stats/Middle/SPEED/Value")
@onready var _a_Stats_LUCK: Label = get_node("Margin/VBox/VBox/Stats/Right/LUCK/Value")
@onready var _a_Options: HBoxContainer = get_node("Margin/VBox/VBox/Options")
@onready var _a_Use: Button = get_node("Margin/VBox/VBox/Options/Use")
@onready var _a_Select: Button = get_node("Margin/VBox/VBox/Options/Select")

func _ready() -> void:
	_a_Use.pressed.connect(_on_Use_pressed)
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Select.set_visible(_e_select_mode)
	_a_VBox.hide()

func display(p_key: StringName) -> void:
	var item_args: FWItemData = Databases.get_data_entry(&"Items", p_key)
	var item_name: String = item_args.get_name_()
	var item_desc: String = item_args.get_desc()
	var item_category_type: StringName = item_args.get_category_type()
	var item_texture: Texture2D = item_args.get_texture()
	_a_Name.set_text(item_name)
	_a_Image.set_texture(item_texture)
	_a_Desc.set_text("[center]%s" % tr(item_desc))
	
	match item_category_type:
		&"Consumable":
			_a_Options.show()
			_a_Stats.hide()
			_a_Use.set_visible(_e_can_use)
		&"Static":
			_a_Options.set_visible(_e_select_mode)
			_a_Stats.hide()
			_a_Use.hide()
		&"Equipable":
			_update_stats(item_args.get_stats())
			_a_Options.set_visible(_e_select_mode)
			_a_Stats.show()
			_a_Use.hide()
	_a_VBox.show()

func close() -> void:
	_a_VBox.hide()

func _update_stats(p_stats: FWStatsData) -> void:
	_a_Stats_HP.set_text(str(p_stats.get_stat(&"HP")))
	_a_Stats_SP.set_text(str(p_stats.get_stat(&"SP")))
	_a_Stats_ATK.set_text(str(p_stats.get_stat(&"ATK")))
	_a_Stats_MAG.set_text(str(p_stats.get_stat(&"MAG")))
	_a_Stats_DEF.set_text(str(p_stats.get_stat(&"DEF")))
	_a_Stats_SPEED.set_text(str(p_stats.get_stat(&"SPEED")))
	_a_Stats_LUCK.set_text(str(p_stats.get_stat(&"LUCK")))

func set_options_disabled(p_disabled: bool) -> void:
	_a_Use.set_disabled(p_disabled)
	_a_Select.set_disabled(p_disabled)

func _on_Use_pressed() -> void:
	use_pressed.emit()

func _on_Select_pressed() -> void:
	select_pressed.emit()
