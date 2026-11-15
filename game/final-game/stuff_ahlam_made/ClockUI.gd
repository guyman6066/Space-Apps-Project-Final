extends Control

@onready var week_label: Label = $week 
@onready var clock_label: Label = $date

func _ready() -> void:
	var time_node = get_tree().root.find_child("TimeManager", true, false)
	
	if time_node:
		time_node.time_changed.connect(_on_time_changed)
	else:
		print("Error: Could not find a node named TimeManager in this scene!")

func _on_time_changed(week: int, day: int, hour: int, minute: int) -> void:
	week_label.text = "WEEK: %d" % week
	
	clock_label.text = "%02d:%02d" % [hour, minute]
