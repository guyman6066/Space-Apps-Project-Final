extends Control

@onready var main_buttons: VBoxContainer = $"Main Buttons"
@onready var settings: Panel = $Settings
@onready var credits: Panel = $credits

#
func _ready():
	main_buttons.visible = true
	settings.visible = false
	credits.visible = false

func _process_delta ():
	pass


func _on_newgame_pressed() -> void:
	print("New Game Pressed")
	get_tree().change_scene_to_file('res://socute.tscn')


func _on_settings_pressed() -> void:
	print("Settings Pressed")
	main_buttons.visible = false
	settings.visible = true

func _on_credits_pressed() -> void:
	print("Credits Pressed")
	main_buttons.visible = false
	credits.visible = true


func _on_Loadgame_pressed() -> void:
	print("Load Game Pressed")
	get_tree().change_scene_to_file('res://Loadgame.tscn')


func _on_back_pressed() -> void:
	_ready()

func _on_back_2_pressed() -> void:
	_ready()
