extends Node2D

@onready var progress_bar = $ProgressBar
@export var next_scene_path: String = "res://TimeManager.tscn"

@export var fake_load_duration: float = 5.0
var elapsed_time: float = 0.0

func _ready() -> void:
	if progress_bar:
		progress_bar.value = 0.0

func _process(delta: float) -> void:
	elapsed_time += delta
	var progress_ratio = clamp(elapsed_time / fake_load_duration, 0.0, 1.0)
	
	if progress_bar:
		progress_bar.value = progress_ratio * 100
		
	if elapsed_time >= fake_load_duration:
		var error = get_tree().change_scene_to_file(next_scene_path)
		if error != OK:
			print("Error: Could not change scene to path: ", next_scene_path)

func trigger_glitch_loading_screen() -> void:
	get_tree().change_scene_to_file("res://stuff_ahlam_made/loadingscreen.tscn")
