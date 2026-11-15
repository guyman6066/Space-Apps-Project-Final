extends Node2D

@export var stun: bool = false

@onready var normal_sprite: Sprite2D = $normal
@onready var sleeping_sprite: Sprite2D = $sleeping
@onready var confirmation_popup: Control = $Control
@onready var confirmation_label: Label = $Control/Confirmation

@onready var character_one: Node2D = $ON
@onready var character_two: Node2D = $OFF

@onready var countdown_label_1: Label = $Countdown1 # Bed 1 (jim)
@onready var countdown_label_2: Label = $Countdown2 # Bed 2 (john)
@onready var countdown_label_3: Label = $Countdown3 # Bed 3 (Samantha)
@onready var countdown_label_4: Label = $Countdown4 # Bed 4 (Carrot)

@onready var sleep_option_1: OptionButton = $Bed3/Sleep3 
@onready var sleep_option_2: OptionButton = $Bed/Sleep
@onready var sleep_option_3: OptionButton = $Bed4/Sleep2 
@onready var sleep_option_4: OptionButton = $Bed2/Sleep4

var pending_duration_seconds: float = 0.0
var pending_character_index: int = 0 

var char_names = {
	1: "jim",
	2: "john",
	3: "Samantha",
	4: "Carrot"
}

var remaining_times = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0}

func _ready() -> void:
	if confirmation_popup:
		confirmation_popup.visible = false
		
	for label in [countdown_label_1, countdown_label_2, countdown_label_3, countdown_label_4]:
		if label:
			label.text = ""
			label.visible = false
			
	if normal_sprite and sleeping_sprite:
		normal_sprite.visible = true
		sleeping_sprite.visible = false
		
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
	get_tree().change_scene_to_file("res://livingroom.tscn")

func _on_right_pressed() -> void:
	get_tree().change_scene_to_file("res://healthlab.tscn")

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://depresurizationchamber.tscn")

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
	remaining_times[bed_id] = duration
	
	var option_btn = _get_option_button_for_bed(bed_id)
	if option_btn:
		option_btn.disabled = true
	
	var target_label = _get_label_for_bed(bed_id)
	if target_label:
		target_label.visible = true
		
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
	
	var wake_unix_time = Time.get_unix_time_from_system() + total_seconds
	var time_dict = Time.get_time_dict_from_unix_time(wake_unix_time)
	var wake_time_str = "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]
	
	var char_name = char_names[bed_id]
	label.text = "%s wakes at %s (-%s)" % [char_name, wake_time_str, countdown_str]

func _wake_up_character(bed_id: int) -> void:
	var label = _get_label_for_bed(bed_id)
	if label:
		label.text = "%s is awake!" % char_names[bed_id]
		
	var option_btn = _get_option_button_for_bed(bed_id)
	if option_btn:
		option_btn.disabled = false
		
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
