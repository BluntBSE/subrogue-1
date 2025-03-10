extends Label
class_name TimeManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time_dict= Time.get_datetime_dict_from_unix_time(GlobalConst.game_date)
	 #Split THE t and everything after it

	text = str(time_dict.year) +"-" +str(time_dict.month) + "-" + str(time_dict.day) + " | " + str(time_dict.hour) + "H " + str(time_dict.minute) + " Min"
	pass

func handle_set_time_scale(time_enum:int):
	dh.dprint(true, self, "Handle set time called")
	GlobalConst.handle_set_time_scale(time_enum)


func _on_normal_button_up(extra_arg_0: int) -> void:
	pass # Replace with function body.
