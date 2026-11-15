extends Control

@onready var main_buttons: VBoxContainer = $"Main Buttons"
@onready var settings: Panel = $Settings
@onready var credits: Panel = $credits
@onready var tutorial: Panel = $Panel  

func _ready():
	main_buttons.visible = true
	settings.visible = false
	credits.visible = false
	tutorial.visible = false


func _on_newgame_pressed() -> void:
	print("New Game Pressed")
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/demoplayscreen.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)


func _on_settings_pressed() -> void:
	print("Settings Pressed")
	main_buttons.visible = false
	settings.visible = true


func _on_credits_pressed() -> void:
	print("Credits Pressed")
	main_buttons.visible = false
	credits.visible = true


func _on_tutorial_pressed() -> void:
	print("Tutorial Pressed")
	main_buttons.visible = false
	tutorial.visible = true


func _on_back_pressed() -> void:
	_ready()

func _on_back_2_pressed() -> void:
	_ready()

func _on_tutorial_back_pressed() -> void:
	_ready()


func _on_abc_6_pressed() -> void:
	print("Tutorial Pressed")
	main_buttons.visible = false
	tutorial.visible = true
