extends MarginContainer

@onready var a_Time = get_node("VBox/Time")
@onready var a_Date = get_node("VBox/Date")

func _process(_p_delta):
	var datetime = Time.get_datetime_dict_from_system()
	var time_text = Global.get_time_text(datetime["hour"], datetime["minute"])
	var date_text = Global.get_date_text(datetime["year"], datetime["month"], datetime["day"])
	a_Time.set_text(time_text)
	a_Date.set_text(date_text)
