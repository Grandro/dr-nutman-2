extends MarginContainer
class_name NutOSContentTaskbarTimeDate

@onready var a_Time: Label = get_node("VBox/Time")
@onready var a_Date: Label = get_node("VBox/Date")

func _process(_p_delta: float) -> void:
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	var time_text: String = Global.get_time_text(datetime[&"hour"], datetime[&"minute"])
	var date_text: String = Global.get_date_text(datetime[&"year"], datetime[&"month"], datetime[&"day"])
	a_Time.set_text(time_text)
	a_Date.set_text(date_text)
