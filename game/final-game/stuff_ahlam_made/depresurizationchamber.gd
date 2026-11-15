extends Node2D

@onready var character_one: Node2D = $ON
@onready var character_two: Node2D = $OFF
@onready var countdown_label: Label = $Countdown 
@onready var depressurizationBG: AudioStreamPlayer2D = $Depressurization_Audio
var depressurizationMusicON = true
var is_ready_playing : bool = true

func _ready():
	update_music()
	Engine.time_scale = 0
	for i in range(5, 0, -1):
		countdown_label.text = "Depressuring..." + str(i)
		await get_tree().create_timer(1, true, false, true).timeout

	countdown_label.text = "Complete!!!" 
	

	Engine.time_scale = 1
	
	is_ready_playing = false
	
	var current_scene_file = get_tree().current_scene.scene_file_path.get_file().get_basename().to_lower()
	if current_scene_file == "demoplayscreen":
		set_character_active(character_one, true)
		set_character_active(character_two, false)
	else:
		set_character_active(character_one, false)
		set_character_active(character_two, true)
		
func update_music():
	if depressurizationMusicON:
		depressurizationBG.play()
	else:
		depressurizationBG.stop()

func set_character_active(character: Node2D, is_on: bool) -> void:
	if character:
		character.visible = is_on


func _on_left_pressed() -> void:
	if is_ready_playing:
		return
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/livingroom.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_right_pressed() -> void:
	if is_ready_playing:
		return
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/livingroom.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_close_pressed() -> void:
	if is_ready_playing:
		return
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/demoplayscreen.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)
