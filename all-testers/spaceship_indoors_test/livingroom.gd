extends Node2D

@onready var character_one: Node2D = $ON
@onready var character_two: Node2D = $OFF
@onready var acc_character: Node2D = $Red
@onready var washroom_label: Label = $washroomcountdown

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
	get_tree().change_scene_to_file("res://bedroom.tscn")

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://depresurizationchamber.tscn")


func _on_washroom_pressed() -> void:
	if acc_character:
		acc_character.visible = false
	if washroom_label:
		washroom_label.visible = true
	for i in range(5, 0, -1):
			washroom_label.text = "Returning in %ds..." % i
			await get_tree().create_timer(1.0).timeout 
	washroom_label.visible = false
	washroom_label.text = ""
	if acc_character:
		acc_character.visible = true
	
