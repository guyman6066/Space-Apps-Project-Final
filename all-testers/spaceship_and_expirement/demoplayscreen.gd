extends Node2D

var current_dug_index: int = -1 
var active_dug_sample_valid: bool = false
var is_clear_mode: bool = false 

@onready var dig_button: Button = $Dig
@onready var test_button: Button = $Save
@onready var close_button: Button = $Close  
@onready var text_label: Label = $text1
@onready var note_label: Label = $note
@onready var label2_label: Label = $Label2
@onready var button_button: Button = $Button
@onready var edit_button: Button = $Edit
@onready var h_scrollbar: HScrollBar = $HScrollBar
@onready var info_label: Label = $info

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

func _ready() -> void:
	dig_button.pressed.connect(_on_dig_pressed)
	test_button.pressed.connect(_on_test_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	for btn in hscroll_buttons:
		if btn:
			btn.pressed.connect(_on_slot_button_pressed.bind(btn))
			
	test_button.disabled = true
	test_button.visible = false
	close_button.visible = false
	text_label.visible = false
	info_label.visible = false
	note_label.visible = false
	label2_label.visible = false
	edit_button.visible = false
	h_scrollbar.visible = false
	for lbl in sample_labels:
		if lbl:
			lbl.visible = false

func _on_dig_pressed() -> void:
	is_clear_mode = false 
	for lbl in sample_labels:
		if lbl:
			lbl.visible = false
	
	current_dug_index = randi() % sample_labels.size()
	active_dug_sample_valid = true
	
	dig_button.disabled = true
	test_button.disabled = false
	test_button.visible = true
	text_label.visible = true
	info_label.visible = false
	close_button.visible = true
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
	
	test_button.visible = false
	dig_button.disabled = true
	test_button.disabled = true
	close_button.visible = true
	text_label.visible = false
	note_label.visible = true
	edit_button.visible = true
	h_scrollbar.visible = true
	label2_label.visible = true
	info_label.visible = true
	info_label.text = "Assign Sample to Slot."

func _on_close_pressed() -> void:
	is_clear_mode = false
	for lbl in sample_labels:
		if lbl:
			lbl.visible = false
		
	close_button.visible = false
	dig_button.disabled = false 
	note_label.visible = false
	label2_label.visible = false
	h_scrollbar.visible = false
	info_label.visible = false
	edit_button.visible = false

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://depresurizationchamber.tscn")

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
	
	info_label.visible = true
	info_label.text = "Successfully stored sample in " + slot_button.name + "!"
	
	active_dug_sample_valid = false
	dig_button.disabled = false
	label2_label.visible = true
	test_button.visible = false

func _on_edit_pressed() -> void:
	is_clear_mode = true
	if info_label:
		info_label.visible = true
		info_label.text = "Clear Mode Active: Click the slot you want to empty."
