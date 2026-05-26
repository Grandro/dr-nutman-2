extends FWItemDragMenuBase
class_name ObjectSetupDiskDrive

signal slot_inserted(p_item_key: StringName)
signal slot_removed()

@onready var _a_Slot: FWItemDragMenuBaseSlot = get_node("Margin/VBox/HBox/Slot")
@onready var _a_Audio_Slot_Insert: AudioStreamPlayer = get_node("Audio/Slot_Insert")

func _ready() -> void:
	_a_inventory = get_node("Margin/VBox/HBox/Inventory")
	super()
	
	_a_Slot.inserted.connect(_on_Slot_inserted)
	_a_Slot.removed.connect(_on_Slot_removed)
	_a_Slot.gui_input.connect(_on_Slot_gui_input)
	_a_Slot.mouse_entered.connect(_on_Slot_mouse_entered.bind(_a_Slot))
	_a_Slot.mouse_exited.connect(_on_Slot_mouse_exited)

func open() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: FWPlayer3D = global_si.get_object(&"Player")
	player.comph().call_comp("Operate", &"disable")
	
	_a_inventory.open()
	
	var item_key: StringName = _a_Slot.get_item_key()
	if item_key != &"":
		_a_inventory.change_item_amount.call_deferred(item_key, -1)
	
	super()

func _close() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: FWPlayer3D = global_si.get_object(&"Player")
	player.comph().call_comp("Operate", &"enable")
	
	super()

func _drop_item_slot(p_item_key: StringName) -> void:
	super(p_item_key)
	_a_Slot.insert(p_item_key)

func _drop_item_revert(p_item_key: StringName) -> void:
	super(p_item_key)
	match _a_item_drag_type:
		&"Slot": _a_Slot.insert(p_item_key)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Slot"] = _a_Slot.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_Slot.load_data(p_data[&"Slot"])

func _on_Slot_inserted(p_item_key: StringName, p_mute: bool) -> void:
	if !p_mute:
		_a_Audio_Slot_Insert.play()
	
	slot_inserted.emit(p_item_key)

func _on_Slot_removed() -> void:
	slot_removed.emit()

func _on_Slot_gui_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Mouse_Left"):
		var item_key: StringName = _a_Slot.get_item_key()
		if item_key != &"":
			_a_Slot.remove()
			_drag_item(_a_Slot, item_key, &"Slot")
