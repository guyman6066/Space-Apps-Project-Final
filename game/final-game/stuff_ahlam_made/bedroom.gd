extends Node2D

@export var stun: bool = false

@onready var normal_sprite: Sprite2D = $normal
@onready var sleeping_sprite: Sprite2D = $sleeping
@onready var confirmation_popup: Control = $Control
@onready var confirmation_label: Label = $Control/Confirmation

@onready var character_one_zzz: Node2D = $Redsleeping     # Bed 1 (jim)
@onready var character_two_zzz: Node2D = $Greensleeping   # Bed 2 (john)
@onready var character_three_zzz: Node2D = $Bluesleeping # Bed 3 (Samantha)
@onready var character_four_zzz: Node2D = $Yellowsleeping # Bed 4 (Carrot)

@onready var countdown_label_1: Label = $Countdown1 
@onready var countdown_label_2: Label = $Countdown2 
@onready var countdown_label_3: Label = $Countdown3 
@onready var countdown_label_4: Label = $Countdown4 

@onready var sleep_option_1: OptionButton = $Sleep3 
@onready var sleep_option_2: OptionButton = $Sleep
@onready var sleep_option_3: OptionButton = $Sleep2 
@onready var sleep_option_4: OptionButton = $Sleep4
@onready var bedroomBG: AudioStreamPlayer2D = $Bedroom_Audio
var bedroomBGMusicOn = true

var pending_duration_seconds: float = 0.0
var pending_character_index: int = 0 

var char_names = {
	1: "Red",
	2: "Green",
	3: "Blue",
	4: "Yellow"
}

var remaining_times = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0}

# bed_id -> astronaut node name (follows the Sleep button each one belongs to)
#const ASTRONAUT_FOR_BED := {
	#1: "newastronaut3",  # Sleep
	#2: "newastronaut",   # Sleep3
	#3: "newastronaut2",  # Sleep2
	#4: "newastronaut4",  # Sleep4
#}

func _ready() -> void:
	update_music()
	if confirmation_popup:
		confirmation_popup.visible = false
		
	for label in [countdown_label_1, countdown_label_2, countdown_label_3, countdown_label_4]:
		if label:
			label.text = ""
			label.visible = false
			
	if normal_sprite and sleeping_sprite:
		normal_sprite.visible = true
		sleeping_sprite.visible = false
	if character_one_zzz: character_one_zzz.visible = false
	if character_two_zzz: character_two_zzz.visible = false
	if character_three_zzz: character_three_zzz.visible = false
	if character_four_zzz: character_four_zzz.visible = false
	
	for bed_id in [1, 2, 3, 4]:
		var left := SceneManager.get_remaining(bed_id)
		if left > 0.0:
			_show_sleeping_ui(bed_id, left)
	
func update_music():
	if bedroomBGMusicOn:
		bedroomBG.play()
	else:
		bedroomBG.stop()
		

func _process(_delta: float) -> void:
	for bed_id in remaining_times.keys():
		if remaining_times[bed_id] > 0.0:
			remaining_times[bed_id] = SceneManager.get_remaining(bed_id)
			if remaining_times[bed_id] <= 0.0:
				_wake_up_character(bed_id)
			else:
				_update_countdown_display(bed_id)

func _on_left_pressed() -> void:
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/livingroom.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_right_pressed() -> void:
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/healthlab.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_close_pressed() -> void:
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/depresurizationchamber.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_sleep_item_selected(index: int) -> void:
	pending_character_index = 1
	_handle_sleep_selection(index, char_names[1])

func _on_sleep_3_item_selected(index: int) -> void:
	pending_character_index = 2
	_handle_sleep_selection(index, char_names[2])

func _on_sleep_2_item_selected(index: int) -> void:
	pending_character_index = 3
	_handle_sleep_selection(index, char_names[3])

func _on_sleep_4_item_selected(index: int) -> void:
	pending_character_index = 4
	_handle_sleep_selection(index, char_names[4])

func _handle_sleep_selection(index: int, char_name: String) -> void:
	var duration_text: String = ""
	
	match index:
		0: 
			pending_duration_seconds = 30 * 60
			duration_text = "30 minutes"
		1: 
			pending_duration_seconds = 1 * 3600
			duration_text = "1 hour"
		2: 
			pending_duration_seconds = (2 * 3600) + (30 * 60)
			duration_text = "2 hrs 30 mins"
		3: 
			pending_duration_seconds = 8 * 3600
			duration_text = "8 hours"
			
	if confirmation_label:
		confirmation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		confirmation_label.custom_minimum_size = Vector2(650, 200)
		confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		confirmation_label.text = "%s will be sleeping for \n%s. \nAre you sure?" % [char_name, duration_text]
		
	if confirmation_popup:
		confirmation_popup.visible = true

func _on_cancel_pressed() -> void:
	if confirmation_popup:
		confirmation_popup.visible = false
	pending_duration_seconds = 0.0
	pending_character_index = 0
	
func _on_confirm_pressed() -> void:	
	if confirmation_popup:
		confirmation_popup.visible = false
	if pending_character_index > 0 and pending_duration_seconds > 0.0:
		start_sleeping_for_bed(pending_character_index, pending_duration_seconds)

func start_sleeping_for_bed(bed_id: int, duration: float) -> void:
	SceneManager.start_sleep(bed_id, duration)
	_show_sleeping_ui(bed_id, duration)
	
func _show_sleeping_ui(bed_id: int, duration: float) -> void:
	remaining_times[bed_id] = duration
	
	var option_btn = _get_option_button_for_bed(bed_id)
	if option_btn:
		option_btn.disabled = true
	
	var target_label = _get_label_for_bed(bed_id)
	if target_label:
		target_label.visible = true
		
	var zzz_node = _get_zzz_for_bed(bed_id)
	if zzz_node:
		zzz_node.visible = true
		
	if bed_id == 1 and normal_sprite and sleeping_sprite:
		normal_sprite.visible = false
		sleeping_sprite.visible = true

func _update_countdown_display(bed_id: int) -> void:
	var label = _get_label_for_bed(bed_id)
	if not label:
		return
		
	var total_seconds = remaining_times[bed_id]

	var hours = int(total_seconds) / 3600
	var minutes = (int(total_seconds) % 3600) / 60
	var seconds = int(total_seconds) % 60
	var countdown_str = "%02d:%02d:%02d" % [hours, minutes, seconds]
	
	var wake_game_time: float = SceneManager.game_now() + total_seconds
	var day_seconds: int = int(fmod(wake_game_time, 86400.0))
	var wake_time_str = "%02d:%02d:%02d" % [day_seconds / 3600, (day_seconds % 3600) / 60, day_seconds % 60]
	
	var char_name = char_names[bed_id]
	label.text = "%s wakes at %s (-%s)" % [char_name, wake_time_str, countdown_str]

func _wake_up_character(bed_id: int) -> void:
	SceneManager.clear_sleep(bed_id)
	var label = _get_label_for_bed(bed_id)
	if label:
		label.text = "%s is awake!" % char_names[bed_id]
		
	var option_btn = _get_option_button_for_bed(bed_id)
	if option_btn:
		option_btn.disabled = false
		
	var zzz_node = _get_zzz_for_bed(bed_id)
	if zzz_node:
		zzz_node.visible = false
		
	if bed_id == 1 and normal_sprite and sleeping_sprite:
		stun = false
		normal_sprite.visible = true
		sleeping_sprite.visible = false

func _get_label_for_bed(bed_id: int) -> Label:
	match bed_id:
		1: return countdown_label_1
		2: return countdown_label_2
		3: return countdown_label_3
		4: return countdown_label_4
	return null
	
func _get_option_button_for_bed(bed_id: int) -> OptionButton:
	match bed_id:
		1: return sleep_option_2
		2: return sleep_option_1
		3: return sleep_option_3
		4: return sleep_option_4
	return null

func _get_zzz_for_bed(bed_id: int) -> Node2D:
	match bed_id:
		1: return character_one_zzz
		2: return character_two_zzz
		3: return character_three_zzz
		4: return character_four_zzz
	return null
