class_name DateTime extends Resource

@export_range(0,59) var minutes: int = 0 
@export_range(0,23) var hours: int = 0 
@export_range(0, 6) var days : int = 0
@export var week: int = 1

var delta_time: float = 0

func increase_by_sec(delta_seconds: float) -> void:
	delta_time += delta_seconds
	if delta_time <1.0 : return
	
	var delta_int_secs = int(delta_time)
	delta_time -= delta_int_secs
	
	minutes += delta_int_secs /60
	hours += minutes / 60
	days += hours/ 24
	week += days / 7
	
	minutes = minutes % 60
	hours = hours % 168
	
	print_debug(str(hours) + ":" + str(minutes))
	
