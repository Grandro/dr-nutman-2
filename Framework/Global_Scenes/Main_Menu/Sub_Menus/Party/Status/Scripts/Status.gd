extends FWItemDragMenuBase
class_name MainMenuSubMenuPartyStatus

signal closed()

@onready var _a_Stats: MainMenuSubMenuPartyStatusStats = get_node("Margin/VBox/HBox/Margin/HBox/VBox_1/Stats")
@onready var _a_Progress: MainMenuSubMenuPartyStatusProgress = get_node("Margin/VBox/HBox/Margin/HBox/VBox_1/Progress")
@onready var _a_Equipable: MainMenuSubMenuPartyStatusEquipable = get_node("Margin/VBox/HBox/Margin/HBox/VBox_2/Equipable")
@onready var _a_Portraits: MainMenuSubMenuPartyPortraits = get_node("Margin/VBox/HBox/Margin/HBox/VBox_2/Portraits")

var _a_pm_key: StringName

func _ready() -> void:
	_a_inventory = get_node("Margin/VBox/HBox/Inventory")
	super()
	
	_a_Equipable.equip_slot_pressed.connect(_on_Slot_pressed)
	_a_Equipable.equip_slot_mouse_entered.connect(_on_Slot_mouse_entered)
	_a_Equipable.equip_slot_mouse_exited.connect(_on_Slot_mouse_exited)
	_a_Portraits.entry_pressed.connect(_on_Portraits_entry_pressed)
	_a_inventory.group_changed.connect(_on_Inventory_group_changed)

func open_(p_pm_key: StringName, p_args: Dictionary) -> void:
	_a_pm_key = p_pm_key
	
	var stats: Dictionary[StringName, int]; stats.assign(p_args[&"Stats"])
	var equipment: Dictionary[StringName, StringName]; equipment.assign(p_args[&"Equipables"])
	var curr_lvl: int = p_args[&"Progress"][&"Lvl"]
	_a_inventory.open()
	_a_Stats.open(p_pm_key, stats)
	_a_Progress.open(p_pm_key, p_args[&"Progress"])
	_a_Equipable.open.call_deferred(p_pm_key, equipment, curr_lvl)
	_a_Portraits.open(p_pm_key)
	
	_update_item_amounts.call_deferred(equipment)
	
	_tutato_explain()
	
	open()

func _close() -> void:
	super()
	closed.emit()

func _update_item_amounts(p_args: Dictionary) -> void:
	for group: StringName in p_args:
		var item_key: StringName = p_args[group]
		if item_key != &"":
			_a_inventory.change_item_amount(item_key, -1)

func _drop_item_slot(p_item_key: StringName) -> void:
	super(p_item_key)
	
	var group: StringName = _a_inventory.get_curr_group()
	var slot_item_key: StringName = _a_slot.get_item_key()
	if slot_item_key != &"":
		_a_slot.remove_(_a_pm_key, group, true)
	_a_slot.insert_(p_item_key, _a_pm_key, group, true)

func _drop_item_revert(p_item_key: StringName) -> void:
	super(p_item_key)

	var group: StringName = _a_inventory.get_curr_group()
	match _a_item_drag_type:
		&"Slot": _a_item_drag_instance.insert_(p_item_key, _a_pm_key, group, true)

func _tutato_explain() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var show_tutato_explain: bool = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_party: bool = progress_si.call_object(&"Tutato", &"get_explain_party")
	if show_tutato_explain && explain_party:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		var key: StringName = &"Tutato_Explain"
		var entry_key: StringName = &"Main_Menu_Party"
		cutscene_system_si.cutscene(key, entry_key, &"Main", &"Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object(&"Tutato", &"set_explain_party", [false])
		
		_a_Back.set_select_diabled(true)

func _can_equip_slot_drop() -> bool:
	var valid: bool = false
	if _a_slot != null:
		var inventory_group: StringName = _a_inventory.get_curr_group()
		var slot_group: StringName = _a_slot.get_group()
		valid = inventory_group == slot_group
	
	return valid

func _on_Slot_pressed(p_instance: MainMenuSubMenuPartyStatusEquipableEquipSlot) -> void:
	var item_key: StringName = p_instance.get_item_key()
	if item_key != &"":
		var group: StringName = _a_inventory.get_curr_group()
		p_instance.remove_(_a_pm_key, group, true)
		_drag_item(p_instance, item_key, &"Slot")

func _on_Portraits_entry_pressed(p_pm_key: StringName, p_args: Dictionary) -> void:
	open_(p_pm_key, p_args)

func _on_Inventory_item_pressed(p_instance: FWItemEntryInventory) -> void:
	var item_key: StringName = p_instance.get_key()
	_a_inventory.change_item_amount(item_key, -1)
	
	_drag_item(p_instance, item_key, &"Inventory")

func _on_Inventory_group_changed(p_group: StringName) -> void:
	var item_key: StringName = _a_Equipable.get_equipped_item_key(p_group)
	if item_key == &"":
		_a_inventory.close_info_equipped()
	else:
		_a_inventory.display_info_equipped(item_key)

func _CB_cutscene_completed(_p_process_type: StringName, p_key: StringName, p_entry_key: StringName) -> void:
	match p_key:
		&"Tutato_Explain":
			match p_entry_key:
				&"Main_Menu_Party":
					_a_Back.set_select_diabled(false)
