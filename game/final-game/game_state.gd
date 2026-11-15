extends Node

signal report_changed(report: String)
signal counter_changed(value: int)
signal countdown_changed(seconds_left: int)

const MAX_COUNT := 10
const COUNTDOWN_SECONDS := 5

var counter := 0
var seconds_left := 0

var _timer := Timer.new()


func _ready() -> void:
	_timer.wait_time = 1.0
	_timer.one_shot = false
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)


func press_button() -> void:
	# No effect if maxed out or a countdown is already running.
	if counter >= MAX_COUNT or not _timer.is_stopped():
		return
	seconds_left = COUNTDOWN_SECONDS
	countdown_changed.emit(seconds_left)
	_timer.start()


func _on_timer_timeout() -> void:
	seconds_left -= 1
	countdown_changed.emit(seconds_left)
	if seconds_left <= 0:
		_timer.stop()
		counter += 1
		counter_changed.emit(counter)
		report_changed.emit(get_report())


func get_report() -> String:
	if counter == 0:
		return "no report"
	elif counter <= 5:
		return "bad report"
	elif counter <= 9:
		return "mid report"
	else:
		return "perfect report"
