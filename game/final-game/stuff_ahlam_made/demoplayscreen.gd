extends Node2D

var current_dug_index: int = -1 
var active_dug_sample_valid: bool = false
var is_clear_mode: bool = false 

var last_dig_position: Vector2 = Vector2(-99999, -99999)
const MOVE_THRESHOLD: float = 30.0 

@onready var text_label: Label = $text1
@onready var note_label: Label = $note
@onready var label2_label: Label = $Label2
@onready var button_button: Button = $Button
@onready var edit_button: Button = $Edit
@onready var h_scrollbar: HScrollBar = $HScrollBar
@onready var info_label: Label = $info
@onready var dig_button: Button = get_node_or_null("dig")
@onready var test_button: Button = get_node_or_null("Save")
@onready var close_button: Button = get_node_or_null("Close")
@onready var label3_label: Label = $Label3
@onready var okay_button: Button = $okay

@onready var sample_labels: Array[Label] = [
	$sample1,
	$sample2,
	$sample3
]

@onready var hscroll_buttons: Array[Button] = [
	$HScrollBar/Sample1,
	$HScrollBar/Sample2,
	$HScrollBar/Sample3,
	$HScrollBar/Sample4,
	$HScrollBar/Sample5,
	$HScrollBar/Sample6,
]

@onready var astronauts_for_button: Array = [$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4]
func get_selected_astronaut() -> Node2D:
	for a in get_tree().get_nodes_in_group("astronauts_for_button"):
		if is_instance_valid(a) and a.is_selected:
			return a
	return null

func any_astronaut_selected() -> bool:
	return get_selected_astronaut() != null

func _ready() -> void:
	if dig_button == null:
		print("DEBUG: Could not find 'Dig' button! Check if it's renamed or nested.")
	else:
		dig_button.pressed.connect(_on_dig_pressed)
		
	if test_button == null:
		print("DEBUG: Could not find 'Save' button! Check if it's renamed or nested.")
	else:
		test_button.pressed.connect(_on_test_pressed)
		
	if close_button == null:
		print("DEBUG: Could not find 'Close' button! Check if it's renamed or nested.")
	else:
		close_button.pressed.connect(_on_close_pressed)
	
	for btn in hscroll_buttons:
		if btn:
			btn.pressed.connect(_on_slot_button_pressed.bind(btn))
			
	if test_button:
		test_button.disabled = false
		test_button.visible = false
	label3_label.visible = false
	okay_button.visible = false
	if close_button:
		close_button.disabled = false
		close_button.visible = false
	if text_label:
		text_label.visible = false
	if info_label:
		info_label.visible = false
	if note_label:
		note_label.visible = false
	if label2_label:
		label2_label.visible = false
	if edit_button:
		edit_button.visible = false
	if h_scrollbar:
		h_scrollbar.visible = false
	for lbl in sample_labels:
		if lbl:
			lbl.visible = false

func _on_dig_pressed() -> void:
	var astronaut: Node2D = null
	for a in get_tree().get_nodes_in_group("astronauts_for_button"):
		if a.is_selected:
			astronaut = a
			break
	if astronaut == null:
		return
	var current_pos = astronaut.global_position
	if last_dig_position != Vector2(-99999, -99999) and current_pos.distance_to(last_dig_position) < MOVE_THRESHOLD:
		if info_label:
			info_label.visible = true
			info_label.text = "You already dug here! Move to a new spot to dig again."
			label3_label.visible = true
			okay_button.visible = true
		return

	is_clear_mode = false 
	for lbl in sample_labels:
		if lbl:
			lbl.visible = false
	
	last_dig_position = current_pos
	
	current_dug_index = randi() % sample_labels.size()
	active_dug_sample_valid = true
	
	if info_label:
		info_label.visible = false
		
	if dig_button:
		dig_button.disabled = true
	if test_button:
		test_button.disabled = false
		test_button.visible = true
	if text_label:
		text_label.visible = true
	if close_button:
		close_button.visible = true
	if label2_label:
		label2_label.visible = true

func _on_test_pressed() -> void:
	if not active_dug_sample_valid:
		return
		
	if current_dug_index >= 0 and current_dug_index < sample_labels.size():
		var target_label = sample_labels[current_dug_index]
		if target_label:
			target_label.visible = true
		else:
			print("Error: Sample label at index ", current_dug_index, " is missing/null in the scene tree!")
	
	if test_button:
		test_button.visible = false
		test_button.disabled = true
	if dig_button:
		dig_button.disabled = true
	if close_button:
		close_button.visible = true
	if text_label:
		text_label.visible = false
	if note_label:
		note_label.visible = true
	if info_label:
		info_label.visible = true
		info_label.text = "Assign Sample to Slot."
	if label2_label:
		label2_label.visible = true
	if edit_button:
		edit_button.visible = true
	if h_scrollbar:
		h_scrollbar.visible = true

func _on_close_pressed() -> void:
	is_clear_mode = false
	for lbl in sample_labels:
		if lbl:
			lbl.visible = false
		
	if close_button:
		close_button.visible = false
	if dig_button:
		dig_button.disabled = false 
	if note_label:
		note_label.visible = false
	if label2_label:
		label2_label.visible = false
	if h_scrollbar:
		h_scrollbar.visible = false
	if info_label:
		info_label.visible = false
	if edit_button:
		edit_button.visible = false
	if test_button:
		test_button.visible = false

func _on_button_pressed() -> void:
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/depresurizationchamber.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func _on_slot_button_pressed(slot_button: Button) -> void:
	if is_clear_mode:
		if GameManager.slot_sample_indices.has(slot_button.name):
			GameManager.slot_sample_indices.erase(slot_button.name)
			info_label.visible = true
			info_label.text = slot_button.name + " has been emptied!"
		else:
			info_label.visible = true
			info_label.text = slot_button.name + " is already empty!"
		is_clear_mode = false 
		return

	if not active_dug_sample_valid:
		info_label.visible = true
		info_label.text = "Dig a sample first before assigning!"
		return
		
	if GameManager.slot_sample_indices.has(slot_button.name):
		info_label.visible = true
		info_label.text = "Error: " + slot_button.name + " already contains a soil sample!"
		return

	GameManager.slot_sample_indices[slot_button.name] = current_dug_index
	
	if info_label:
		info_label.visible = true
	info_label.text = "Successfully stored sample in " + slot_button.name + "!"
	
	active_dug_sample_valid = false
	if dig_button:
		dig_button.disabled = false
	if label2_label:
		label2_label.visible = true
	if test_button:
		test_button.visible = false

func _on_edit_pressed() -> void:
	is_clear_mode = true
	if info_label:
		info_label.visible = true
		info_label.text = "Clear Mode Active: Click the slot you want to empty."


func _on_okay_pressed() -> void:
	label3_label.visible = false
	okay_button.visible = false
	info_label.visible = false


func _on_plant_pressed() -> void:
	if get_selected_astronaut() == null:
		return
	get_tree().change_scene_to_file('res://stuff_ahlam_made/plantgrowing.tscn')


func _on_healthtrackers_pressed() -> void:
	if get_selected_astronaut() == null:
		return
	get_tree().change_scene_to_file('res://stuff_ahlam_made/TimeManager.tscn')
