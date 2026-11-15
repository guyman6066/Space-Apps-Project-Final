extends Control

# Signals: anything can connect to these later.
signal report_changed(report: String)
signal counter_changed(value: int)
signal countdown_changed(seconds_left: int)

const MAX_COUNT := 10
const COUNTDOWN_SECONDS := 5

var counter := 0
var seconds_left := 0

@onready var timer: Timer = $Timer
@onready var button: Button = $VBoxContainer/Button
@onready var countdown_label: Label = $VBoxContainer/CountdownLabel
@onready var counter_label: Label = $VBoxContainer/CounterLabel
@onready var report_label: Label = $VBoxContainer/ReportLabel


func _ready() -> void:
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	button.pressed.connect(_on_button_pressed)

	# Debug display: remove these three lines (and the handlers below)
	# when you connect the signals to something else.
	report_changed.connect(_debug_show_report)
	counter_changed.connect(_debug_show_counter)
	countdown_changed.connect(_debug_show_countdown)

	# Push the initial state out so the display starts correct.
	counter_changed.emit(counter)
	report_changed.emit(get_report())
	countdown_changed.emit(0)


func _on_button_pressed() -> void:
	# No effect if maxed out or a countdown is already running.
	if counter >= MAX_COUNT or not timer.is_stopped():
		return
	seconds_left = COUNTDOWN_SECONDS
	countdown_changed.emit(seconds_left)
	timer.start()


func _on_timer_timeout() -> void:
	seconds_left -= 1
	countdown_changed.emit(seconds_left)
	if seconds_left <= 0:
		timer.stop()
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


# --- Debug display handlers ---

func _debug_show_report(report: String) -> void:
	report_label.text = "Report: " + report

func _debug_show_counter(value: int) -> void:
	counter_label.text = "Counter: %d / %d" % [value, MAX_COUNT]

func _debug_show_countdown(secs: int) -> void:
	countdown_label.text = "" if secs <= 0 else "Countdown: %d" % secs
