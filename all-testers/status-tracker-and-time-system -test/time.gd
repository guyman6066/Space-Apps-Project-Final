extends Node

signal time_changed(week: int, day: int, hour: int, minute: int)

@export var day_length_in_real_seconds: float = 1200.0 
@export var current_time: float = 28800.0 

const SECONDS_IN_DAY = 86400
const SECONDS_IN_HOUR = 3600
const SECONDS_IN_MINUTE = 60
const DAYS_IN_WEEK = 7

var current_week: int = 1
var total_days: int = 1 
var current_day_of_week: int = 1 

var current_hour: int = 0
var current_minute: int = 0
var time_scale: float

func _ready() -> void:
	time_scale = SECONDS_IN_DAY / day_length_in_real_seconds

func _process(delta: float) -> void:
	current_time += delta * time_scale
	
	if current_time >= SECONDS_IN_DAY:
		current_time -= SECONDS_IN_DAY
		total_days += 1
		
		current_week = int((total_days - 1) / DAYS_IN_WEEK) + 1
		current_day_of_week = ((total_days - 1) % DAYS_IN_WEEK) + 1
		
	_calculate_time()

func _calculate_time() -> void:
	var new_hour = int(current_time / SECONDS_IN_HOUR)
	var new_minute = int(fmod(current_time, SECONDS_IN_HOUR) / SECONDS_IN_MINUTE)
	
	if new_hour != current_hour or new_minute != current_minute:
		current_hour = new_hour
		current_minute = new_minute
		time_changed.emit(current_week, current_day_of_week, current_hour, current_minute)
