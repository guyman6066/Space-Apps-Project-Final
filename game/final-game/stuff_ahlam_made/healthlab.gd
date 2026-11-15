extends Node2D

@export var stun: bool = false

@onready var confirmation_popup: Control = $Control
@onready var confirmation_label: Label = $Control/Confirmation

@onready var character_select_option: OptionButton = $CharacterSelect

@onready var sleepingbed1: Array[Node2D] = [
	$Redsleeping1, $Bluesleeping1,
	$Greensleeping1, $Yellowsleeping1,
]
@onready var sleepingbed2: Array[Node2D] = [
	$Redsleeping2, $Bluesleeping2,
	$Greensleeping2, $Yellowsleeping2,
]

@onready var countdown_label_1: Label = $Countdown1
@onready var countdown_label_2: Label = $Countdown2 

@onready var sleep_option_1: OptionButton = $leep1
@onready var sleep_option_2: OptionButton = $Sleep2
@onready var healthlabBG: AudioStreamPlayer2D = $HealthLab_Audio
var healthlabMusicOn = true

var pending_duration_seconds: float = 0.0
var pending_duration_index: int = -1
var pending_bed_id: int = 0 
var pending_character_id: int = -1 

var char_names = {
	1: "Red",
	2: "Blue",
	3: "Green",
	4: "Yellow"
}

var active_bed_characters = {}
var remaining_times = {1: 0.0, 2: 0.0}

func _ready() -> void:
	update_music()
	if confirmation_popup:
		confirmation_popup.visible = false
		confirmation_popup.custom_minimum_size = Vector2(650, 200)
		
	if confirmation_label:
		confirmation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		confirmation_label.custom_minimum_size = Vector2(650, 150)
		confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		confirmation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		confirmation_label.text = ""
		
	for label in [countdown_label_1, countdown_label_2]:
		if label:
			label.text = ""
			label.visible = false
			
	if character_select_option:
		character_select_option.clear()
		character_select_option.add_item("Red")    
		character_select_option.add_item("Blue")   
		character_select_option.add_item("Green")  
		character_select_option.add_item("Yellow") 
		character_select_option.select(-1)
			
	for sprite in sleepingbed1:
		if sprite: sprite.visible = false
	for sprite in sleepingbed2:
		if sprite: sprite.visible = false
		
	if character_select_option:
		character_select_option.visible = false
		
func update_music():
	if healthlabMusicOn:
		healthlabBG.play()
	else:
		healthlabBG.stop()

func _process(delta: float) -> void:
	for bed_id in remaining_times.keys():
		if remaining_times[bed_id] > 0.0:
			remaining_times[bed_id] -= delta
			if remaining_times[bed_id] <= 0.0:
				remaining_times[bed_id] = 0.0
				_wake_up_character(bed_id)
			else:
				_update_countdown_display(bed_id)

func _on_left_pressed() -> void:
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/bedroom.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_right_pressed() -> void:
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/mobilitywing.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_close_pressed() -> void:
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/depresurization.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_character_select_item_selected(index: int) -> void:
	pending_character_id = index + 1
	
	if pending_bed_id > 0 and pending_duration_index != -1:
		_handle_sleep_selection(pending_duration_index)
	else:
		if confirmation_label and confirmation_label.text.begins_with("Please select"):
			if confirmation_popup:
				confirmation_popup.visible = false
				var astronaut: Node2D = $newastronaut
				astronaut.visible = true
				var astronaut2: Node2D = $newastronaut2
				astronaut2.visible = true
				var astronaut3: Node2D = $newastronaut3
				astronaut3.visible = true
				var astronaut4: Node2D = $newastronaut4
				astronaut4.visible = true
			confirmation_label.text = ""

func _on_sleep_1_item_selected(index: int) -> void:
	pending_bed_id = 1
	pending_duration_index = index
	_handle_sleep_selection(index)
	if sleep_option_1:
		sleep_option_1.select(-1)

func _on_sleep_2_item_selected(index: int) -> void:
	pending_bed_id = 2 
	pending_duration_index = index
	_handle_sleep_selection(index)
	if sleep_option_2:
		sleep_option_2.select(-1)
func _handle_sleep_selection(index: int) -> void:
	if pending_character_id == -1:
		if character_select_option:
			character_select_option.visible = true
			
		if confirmation_label:
			confirmation_label.text = "Please select a character\nfrom the dropdown menu first!"
			
		if confirmation_popup:
			confirmation_popup.visible = true
			
			# Safely hide all astronauts without nesting them incorrectly
			var astronaut = get_node_or_null("newastronaut")
			if astronaut: astronaut.visible = false
			
			var astronaut2 = get_node_or_null("newastronaut2")
			if astronaut2: astronaut2.visible = false
			
			var astronaut3 = get_node_or_null("newastronaut3")
			if astronaut3: astronaut3.visible = false
			
			var astronaut4 = get_node_or_null("newastronaut4")
			if astronaut4: astronaut4.visible = false
		return # Stop here so it doesn't process the healing yet

	for bed_id in active_bed_characters.keys():
		if active_bed_characters[bed_id] == pending_character_id and remaining_times[bed_id] > 0.0:
			var char_name_busy = char_names.get(pending_character_id, "Character")
			if confirmation_label:
				confirmation_label.text = "%s is already healing in Bed %d!" % [char_name_busy, bed_id]
			if confirmation_popup:
				confirmation_popup.visible = true
				
				var astronaut = get_node_or_null("newastronaut")
				if astronaut: astronaut.visible = false
				
				var astronaut2 = get_node_or_null("newastronaut2")
				if astronaut2: astronaut2.visible = false
				
				var astronaut3 = get_node_or_null("newastronaut3")
				if astronaut3: astronaut3.visible = false
				
				var astronaut4 = get_node_or_null("newastronaut4")
				if astronaut4: astronaut4.visible = false
				
			pending_bed_id = 0
			pending_duration_index = -1
			return

	if character_select_option:
		character_select_option.visible = false

	var duration_text: String = ""
	match index:
		0: 
			pending_duration_seconds = 30 * 60
			duration_text = "30 mins"
		1: 
			pending_duration_seconds = 1 * 3600
			duration_text = "1 hour"
		2: 
			pending_duration_seconds = (2 * 3600) + (30 * 60)
			duration_text = "2 hr 30 mins"
		3: 
			pending_duration_seconds = 8 * 3600
			duration_text = "8 hours"
			
	var char_name = char_names.get(pending_character_id, "Character")
	if confirmation_label:
		confirmation_label.text = "%s will be healing \n for %s of time." % [char_name, duration_text]
		
	if confirmation_popup:
		confirmation_popup.visible = true
		
		var astronaut = get_node_or_null("newastronaut")
		if astronaut: astronaut.visible = false
		
		var astronaut2 = get_node_or_null("newastronaut2")
		if astronaut2: astronaut2.visible = false
		
		var astronaut3 = get_node_or_null("newastronaut3")
		if astronaut3: astronaut3.visible = false
		
		var astronaut4 = get_node_or_null("newastronaut4")
		if astronaut4: astronaut4.visible = false
		

func _on_cancel_pressed() -> void:
	if confirmation_popup:
		confirmation_popup.visible = false
		var astronaut: Node2D = $newastronaut
		astronaut.visible = true
		var astronaut2: Node2D = $newastronaut2
		astronaut2.visible = true
		var astronaut3: Node2D = $newastronaut3
		astronaut3.visible = true
		var astronaut4: Node2D = $newastronaut4
		astronaut4.visible = true
	pending_duration_seconds = 0.0
	pending_duration_index = -1
	pending_bed_id = 0
	pending_character_id = -1
	if character_select_option:
		character_select_option.select(-1)
		character_select_option.visible = false
	
func _on_confirm_pressed() -> void:
	if pending_character_id == -1:
		if confirmation_popup:
			confirmation_popup.visible = false
			var astronaut = get_node_or_null("newastronaut")
			if astronaut:
				astronaut.visible = true

			var astronaut2 = get_node_or_null("newastronaut2")
			if astronaut2:
				astronaut2.visible = true

			var astronaut3 = get_node_or_null("newastronaut3")
			if astronaut3:
				astronaut3.visible = true
			var astronaut4 = get_node_or_null("newastronaut4")
			if astronaut4:
				astronaut4.visible = true
		return

	if confirmation_popup:
		confirmation_popup.visible = false
		var astronaut: Node2D = $newastronaut
		astronaut.visible = true
		var astronaut2: Node2D = $newastronaut2
		astronaut2.visible = true
		var astronaut3: Node2D = $newastronaut3
		astronaut3.visible = true
		var astronaut4: Node2D = $newastronaut4
		astronaut4.visible = true
		
	if pending_bed_id > 0 and pending_duration_seconds > 0.0:
		active_bed_characters[pending_bed_id] = pending_character_id
		start_sleeping_for_bed(pending_bed_id, pending_duration_seconds)
	
	pending_duration_seconds = 0.0
	pending_duration_index = -1
	pending_bed_id = 0
	pending_character_id = -1
	if character_select_option:
		character_select_option.select(-1)
		character_select_option.visible = false

func start_sleeping_for_bed(bed_id: int, duration: float) -> void:
	remaining_times[bed_id] = duration
	
	var option_btn = _get_option_button_for_bed(bed_id)
	if option_btn:
		option_btn.disabled = true
	
	var target_label = _get_label_for_bed(bed_id)
	if target_label:
		target_label.visible = true
		
	var char_id = active_bed_characters[bed_id]
	var sprite_array = sleepingbed1 if bed_id == 1 else sleepingbed2
	
	for i in range(sprite_array.size()):
		var sprite = sprite_array[i]
		if sprite:
			sprite.visible = (i == (char_id - 1))

func _update_countdown_display(bed_id: int) -> void:
	var label = _get_label_for_bed(bed_id)
	if not label:
		return
		
	var total_seconds = remaining_times[bed_id]
	var char_id = active_bed_characters.get(bed_id, 1)
	var char_name = char_names.get(char_id, "Character")

	var hours = int(total_seconds) / 3600
	var minutes = (int(total_seconds) % 3600) / 60
	var seconds = int(total_seconds) % 60
	var countdown_str = "%02d:%02d:%02d" % [hours, minutes, seconds]
	
	var wake_unix_time = Time.get_unix_time_from_system() + total_seconds
	var time_dict = Time.get_time_dict_from_unix_time(wake_unix_time)
	var wake_time_str = "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]
	
	label.text = "%s finishes healing at %s (-%s)" % [char_name, wake_time_str, countdown_str]

func _wake_up_character(bed_id: int) -> void:
	var char_id = active_bed_characters.get(bed_id, 1)
	var char_name = char_names.get(char_id, "Character")
	
	var label = _get_label_for_bed(bed_id)
	if label:
		label.text = "%s finished healing!" % char_name
		
	var option_btn = _get_option_button_for_bed(bed_id)
	if option_btn:
		option_btn.disabled = false
		
	var sprite_array = sleepingbed1 if bed_id == 1 else sleepingbed2
	for sprite in sprite_array:
		if sprite:
			sprite.visible = false
			
	active_bed_characters.erase(bed_id)

func _get_label_for_bed(bed_id: int) -> Label:
	match bed_id:
		1: return countdown_label_1
		2: return countdown_label_2
	return null

func _get_option_button_for_bed(bed_id: int) -> OptionButton:
	match bed_id:
		1: return sleep_option_1
		2: return sleep_option_2
	return null
