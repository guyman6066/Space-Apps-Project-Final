extends Node2D

@onready var character_one: Node2D = $ON
@onready var character_two: Node2D = $OFF

func _ready() -> void:
	var current_scene_file = get_tree().current_scene.scene_file_path.get_file().get_basename().to_lower()
	if current_scene_file == "demoplayscreen":
		set_character_active(character_one, true)
		set_character_active(character_two, false)
	else:
		set_character_active(character_one, false)
		set_character_active(character_two, true)

func set_character_active(character: Node2D, is_on: bool) -> void:
	if character:
		character.visible = is_on


func _on_left_pressed() -> void:
	get_tree().change_scene_to_file("res://healthlab.tscn")


func _on_right_pressed() -> void:
	get_tree().change_scene_to_file("res://livingroom.tscn")


func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://depresurizationchamber.tscn")
