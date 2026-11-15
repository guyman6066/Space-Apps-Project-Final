extends Control

@onready var button: Button = $VBoxContainer/Button
@onready var countdown_label: Label = $VBoxContainer/CountdownLabel
@onready var counter_label: Label = $VBoxContainer/CounterLabel
@onready var report_label: Label = $VBoxContainer/ReportLabel

func _ready() -> void:
	button.visible = true
	Radiation.radiation_measure_center_built.connect(_is_structure_built)
	# Debug display: remove these and the handlers below when you
	# connect the signals to something else.
	GameState.report_changed.connect(_debug_show_report)
	GameState.counter_changed.connect(_debug_show_counter)
	GameState.countdown_changed.connect(_debug_show_countdown)

	# Sync with whatever state already exists (important after a scene switch).
	_debug_show_report(GameState.get_report())
	_debug_show_counter(GameState.counter)
	_debug_show_countdown(GameState.seconds_left)

# --- Debug display handlers ---

func _is_structure_built():
	button.visible = true
	print("Radiation Measure Center is built")

func _debug_show_report(report: String) -> void:
	report_label.text = "Report: " + report

func _debug_show_counter(value: int) -> void:
	counter_label.text = "Counter: %d / %d" % [value, GameState.MAX_COUNT]

func _debug_show_countdown(secs: int) -> void:
	countdown_label.text = "" if secs <= 0 else "Countdown: %d" % secs 
