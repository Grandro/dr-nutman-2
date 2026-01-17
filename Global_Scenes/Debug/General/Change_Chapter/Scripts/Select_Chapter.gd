extends CanvasLayer
class_name DebugGeneralChangeChapterSelect

var _a_Chapter_Entry_Scene: PackedScene = preload("res://Global_Scenes/Debug/General/Change_Chapter/Chapter_Entry.tscn")

@onready var _a_Return: Button = get_node("Control/VBox/Return")
@onready var _a_Chapters_Heading: RichTextLabel = get_node("Control/VBox/Scroll/Chapters/Heading")
@onready var _a_Curr: Label = get_node("Control/VBox/Scroll/Chapters/Curr/Value")
@onready var _a_Chapters: VBoxContainer = get_node("Control/VBox/Scroll/Chapters/VBox")

func _ready() -> void:
	_a_Return.pressed.connect(_on_Return_pressed)
	Databases.data_loaded.connect(_on_Databases_data_loaded)
	
	_a_Chapters_Heading.set_text("[center][u]%s" % tr(&"DEBUG_GENERAL_CHAPTERS"))
	
	close()

func open() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var chapter: StringName = progress_si.get_chapter()
	for child: Button in _a_Chapters.get_children():
		var child_chapter: StringName = child.get_text()
		child.set_visible(child_chapter != chapter)
	_a_Curr.set_text(chapter)
	
	show()

func close() -> void:
	hide()

func _create_chapter_list() -> void:
	var chapters: Array[StringName] = Progress.get_chapters()
	for chapter: StringName in chapters:
		var instance: Button = _a_Chapter_Entry_Scene.instantiate()
		instance.pressed.connect(_on_Chapter_Select_pressed.bind(chapter))
		instance.set_text(chapter)
		
		_a_Chapters.add_child(instance)

func _on_Return_pressed() -> void:
	close()

func _on_Databases_data_loaded() -> void:
	_create_chapter_list()

func _on_Chapter_Select_pressed(p_chapter: StringName) -> void:
	Progress.change_chapter(p_chapter)
	close()
