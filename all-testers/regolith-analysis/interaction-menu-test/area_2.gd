extends Node2D

@onready var popup_label: Label = $Label

var player_inside: bool = false
var sample_already_obtained: bool = false

func _ready() -> void:
	popup_label.visible = false
	popup_label.text = ""

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D" or body.is_in_group("main_character"):
		player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D" or body.is_in_group("main_character"):
		player_inside = false
		popup_label.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("collectdirt") and player_inside:
		trigger_popup_message()

func trigger_popup_message() -> void:
	if sample_already_obtained:
		popup_label.text = "already obtained sample!"
	else:
		sample_already_obtained = true
		GlobalTracker.global_soil_count += 1
		popup_label.text = "soil sample obtained " + str(GlobalTracker.global_soil_count) + "/3"
	
	popup_label.visible = true
	popup_label.modulate.a = 1.0
	popup_label.position = Vector2(0, -20) # Resets the starting height
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_label, "position:y", -50.0, 1.5)
	tween.tween_property(popup_label, "modulate:a", 0.0, 1.5)
	tween.chain().tween_callback(func(): popup_label.visible = false)
	
	
