extends Node2D

const INT_MENU_UI = preload("res://UI/InteractionMenu/int_menu_ui.tscn")

var player_is_near: bool = false
var menu_instance: CanvasLayer = null

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D" or body.is_in_group("main_character"):
		player_is_near = true

func _on_detect_area_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D" or body.is_in_group("main_character"):
		player_is_near = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_is_near:
		if is_instance_valid(menu_instance):
			return
		
		menu_instance = INT_MENU_UI.instantiate()
		get_tree().root.add_child(menu_instance)
		menu_instance.open_menu()
