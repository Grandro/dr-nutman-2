extends MiniGameRightOnTheNutGameBase
class_name MiniGameRightOnTheNutGamePreview

func open() -> void:
	open_qt_bar(true)
	super()

func close() -> void:
	close_qt_bar()
	super()
