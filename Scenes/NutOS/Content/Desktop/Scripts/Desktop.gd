extends Control

signal app_registered(p_key)
signal app_unregistered(p_key)
signal app_installed(p_key)
signal app_uninstalled(p_key)
signal app_opened(p_key)
signal app_closed(p_key)
signal app_focus_entered(p_key)
signal app_option_selected(p_key, p_option, p_value)

const _a_APP_SHORTCUT_PATH = "res://Scenes/NutOS/Content/Desktop/App_Shortcuts/%s.tscn"

@export var _e_cell_size: Vector2i = Vector2i(64, 64)
@export var _e_cell_offset: Vector2i = Vector2i(22, 23)
@export var _e_draw_grid: bool = false

@onready var _a_App_Shortcuts = get_node("App_Shortcuts")
@onready var _a_Apps = get_node("Apps")
@onready var _a_Selection_Rect = get_node("Selection_Rect")
@onready var _a_App_Options = get_node("App_Options")

var _a_rows = -1
var _a_columns = -1
var _a_cells = {} # Match cell to App_Shortcut instance
var _a_shortcuts = {} # Match app key to App_Shortcut instance
var _a_selected = [] # Selected App_Shortcuts
var _a_app_paths = {} # Match app key to path
var _a_registered_apps = [] # app keys
var _a_open_apps = {} # Match app key to app instance

var _a_apps_save_data = {}

func _ready():
	_a_Selection_Rect.rect_updated.connect(_on_Selection_rect_updated)
	_a_App_Options.option_selected.connect(_on_App_Options_option_selected)
	
	var total_cell_size = _e_cell_size + _e_cell_offset
	_a_rows = int(size.x / total_cell_size.x)
	_a_columns = int(size.y / total_cell_size.y)
	
	_a_App_Options.set_layer(1026)
	
	_init_cells()

func _physics_process(_p_delta):
	queue_redraw()

func register_app(p_key):
	_a_registered_apps.push_back(p_key)
	
	app_registered.emit(p_key)

func deregister_app(p_key):
	_a_registered_apps.erase(p_key)
	
	app_unregistered.emit(p_key)

func open_app(p_key):
	if _a_open_apps.has(p_key):
		return
	
	var path = _a_app_paths[p_key]
	var scene = load(path)
	var instance = scene.instantiate()
	var save_data = _a_apps_save_data[p_key]
	instance.closed.connect(_on_App_closed.bind(instance))
	instance.focus_entered.connect(_on_App_focus_entered.bind(p_key))
	instance.option_selected.connect(_on_App_option_selected)
	instance.set_key(p_key)
	
	match p_key:
		"Settings":
			instance.app_installed.connect(_on_Settings_app_installed)
			instance.app_uninstalled.connect(_on_Settings_app_uninstalled)
			instance.set_desktop(self)
	
	instance.open.call_deferred(save_data)
	app_opened.emit(p_key)
	
	_a_open_apps[p_key] = instance
	_a_Apps.add_child(instance)

func focus_app(p_key):
	var instance = _a_open_apps[p_key]
	instance.grab_focus()

func _init_cells():
	for y in _a_columns + 1:
		for x in _a_rows + 1:
			var cell = Vector2i(x, y)
			_a_cells[cell] = null

func _instantiate_app_shortcut(p_key, p_cell):
	var scene = load(_a_APP_SHORTCUT_PATH % p_key)
	var instance = scene.instantiate()
	var pos = _grid_to_pos(p_cell)
	instance.activated.connect(_on_App_Shortcut_activated.bind(instance))
	instance.left_pressed.connect(_on_App_Shortcut_left_pressed.bind(instance))
	instance.left_released.connect(_on_App_Shortcut_left_released)
	instance.right_pressed.connect(_on_App_Shortcut_right_pressed.bind(instance))
	instance.set_global_position(pos)
	instance.set_key(p_key)
	instance.set_cell(p_cell)
	
	_a_cells[p_cell] = instance
	_a_shortcuts[p_key] = instance
	_a_app_paths[p_key] = instance.get_app_path()
	_a_apps_save_data[p_key] = {}
	_a_App_Shortcuts.add_child(instance)

func _move_app_to_cell(p_instance, p_cell):
	var curr_app = _a_cells[p_cell]
	if curr_app != null && curr_app != p_instance:
		var old_cell = p_instance.get_cell()
		_move_app_to_cell(curr_app, old_cell)
	
	_a_cells[p_cell] = p_instance
	
	var new_pos = _grid_to_pos(p_cell)
	p_instance.set_global_position(new_pos)
	p_instance.set_cell(p_cell)

func _pos_to_grid(p_pos):
	var total_cell_size = _e_cell_size + _e_cell_offset
	var half_offset_pos = p_pos + (_e_cell_offset / 2.0)
	var cell = Vector2i.ZERO
	cell.x = int(floor(half_offset_pos.x / total_cell_size.x))
	cell.y = int(floor(half_offset_pos.y / total_cell_size.y))
	
	return cell

func _grid_to_pos(p_cell):
	# Returns Top_Left position
	var total_cell_size = _e_cell_size + _e_cell_offset
	var pos = p_cell * total_cell_size
	
	return pos

func _clear_selected():
	for instance in _a_selected:
		instance.fake_focus(false)
	_a_selected.clear()

func _app_installed(p_key):
	for cell in _a_cells:
		var instance = _a_cells[cell]
		if instance != null:
			continue
		
		_instantiate_app_shortcut(p_key, cell)
		break
	
	app_installed.emit(p_key)

func _set_selected(p_selected):
	for instance in _a_selected:
		instance.fake_focus(false)
	for instance in p_selected:
		instance.fake_focus(true)
	_a_selected = p_selected

func _is_cell_in_grid(p_cell):
	if p_cell.x < 0 || p_cell.x > _a_rows:
		return false
	if p_cell.y < 0 || p_cell.y > _a_columns:
		return false
	
	return true

func _draw():
	_draw_grid()

func _draw_grid():
	if !_e_draw_grid:
		return
	
	var size_ = get_size()
	var total_cell_size = _e_cell_size + _e_cell_offset
	
	var from = Vector2i.ZERO
	var to = Vector2i.ZERO
	var x = _e_cell_size.x
	while x < size_.x:
		# Cell
		from = Vector2i(x, 0)
		to = Vector2i(x, size_.y)
		draw_line(from, to, Color.WHITE)
		
		# Offset
		from = Vector2i(x + _e_cell_offset.x, 0)
		to = Vector2i(x + _e_cell_offset.x, size_.y)
		draw_line(from, to, Color.WHITE)
		
		x += total_cell_size.x
		
		var y = _e_cell_size.y
		while y < size_.y:
			# Cell
			from = Vector2i(0, y)
			to = Vector2i(size_.x, y)
			draw_line(from, to, Color.WHITE)
			
			# Offset
			from = Vector2i(0, y + _e_cell_offset.y)
			to = Vector2i(size_.x, y + _e_cell_offset.y)
			draw_line(from, to, Color.WHITE)
			
			y += total_cell_size.y

func get_registered_apps():
	return _a_registered_apps

func is_app_registered(p_key):
	return _a_registered_apps.has(p_key)

func is_app_open(p_key):
	return _a_open_apps.has(p_key)

func is_app_installed(p_key):
	return _a_shortcuts.has(p_key)

func get_save_data():
	var data = {}
	data["Registered_Apps"] = _a_registered_apps
	
	data["App_Shortcuts"] = {}
	for child in _a_App_Shortcuts.get_children():
		var key = child.get_key()
		var cell = child.get_cell()
		data["App_Shortcuts"][cell] = key
	
	for child in _a_Apps.get_children():
		var key = child.get_key()
		_a_apps_save_data[key] = child.get_save_data(false)
		_a_apps_save_data[key]["Open"] = true
	data["Apps"] = _a_apps_save_data
	
	return data

func load_data(p_data):
	_a_registered_apps = p_data["Registered_Apps"]
	
	var app_shortcut_args = p_data["App_Shortcuts"]
	for cell in app_shortcut_args:
		var key = app_shortcut_args[cell]
		_instantiate_app_shortcut(key, cell)
	
	_a_apps_save_data = p_data["Apps"]
	for key in _a_apps_save_data:
		var args = _a_apps_save_data[key]
		if args.is_empty():
			continue
		
		var open = args["Open"]
		if open:
			open_app(key)

func load_data_init():
	register_app("Settings")
	_app_installed("Settings")

func _on_Selection_rect_updated(p_rect):
	_clear_selected()
	
	var selected = []
	for child in _a_App_Shortcuts.get_children():
		var child_rect = child.get_rect()
		if p_rect.intersects(child_rect):
			selected.push_back(child)
	_set_selected(selected)

func _on_App_Options_option_selected(p_option):
	match p_option:
		"Open":
			for instance in _a_selected:
				var key = instance.get_key()
				open_app(key)

func _on_App_closed(p_save_data, p_instance):
	var key = p_instance.get_key()
	_a_apps_save_data[key] = p_save_data
	_a_apps_save_data[key]["Open"] = false
	
	app_closed.emit(key)
	
	_a_open_apps.erase(key)
	p_instance.queue_free()

func _on_App_focus_entered(p_key):
	app_focus_entered.emit(p_key)

func _on_App_option_selected(p_key, p_option, p_value):
	app_option_selected.emit(p_key, p_option, p_value)

func _on_Settings_app_installed(p_key):
	_app_installed(p_key)

func _on_Settings_app_uninstalled(p_key):
	var instance = _a_shortcuts[p_key]
	var cell = instance.get_cell()
	_a_cells[cell] = null
	_a_shortcuts.erase(p_key)
	_a_selected.erase(instance)
	_a_app_paths.erase(p_key)
	instance.queue_free()
	
	app_uninstalled.emit(p_key)

func _on_App_Shortcut_activated(p_instance):
	_set_selected([p_instance])
	
	var key = p_instance.get_key()
	open_app(key)

func _on_App_Shortcut_left_pressed(p_instance):
	if !_a_selected.has(p_instance):
		_set_selected([p_instance])
	
	var mouse_pos = get_global_mouse_position()
	for instance in _a_selected:
		var pos = instance.get_global_position()
		instance.set_drag_offset(mouse_pos - pos)
		instance.set_physics_process(true)
		
		var cell = instance.get_cell()
		_a_cells[cell] = null

func _on_App_Shortcut_left_released():
	for instance in _a_selected:
		instance.set_physics_process(false)
	
	var revert = false
	for instance in _a_selected:
		var pos = instance.get_position()
		var size_ = instance.get_size()
		var cell = _pos_to_grid(pos + size_ / 2)
		if !_is_cell_in_grid(cell):
			revert = true
			break
	
	for instance in _a_selected:
		if revert:
			var curr_cell = instance.get_cell()
			_move_app_to_cell(instance, curr_cell)
		else:
			var pos = instance.get_position()
			var size_ = instance.get_size()
			var cell = _pos_to_grid(pos + size_ / 2)
			_move_app_to_cell(instance, cell)

func _on_App_Shortcut_right_pressed(p_instance):
	if !_a_selected.has(p_instance):
		_set_selected([p_instance])
	
	var mouse_pos = get_global_mouse_position()
	_a_App_Options.open(mouse_pos)
