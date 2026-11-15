extends Node2D

var current_sample_label: Label = null
var discovered_reports: Array = []

@onready var dig_button: Button = $Dig
@onready var test_button: Button = $test
@onready var close_button: Button = $Close  
@onready var text_label: Label = $text1
@onready var note_label: Label = $note
@onready var label2_label: Label = $Label2

@onready var sample_labels: Array[Label] = [
	$sample1,
	$sample2,
	$sample3
]

func _ready() -> void:
	dig_button.pressed.connect(_on_dig_pressed)
	test_button.pressed.connect(_on_test_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	test_button.disabled = true
	test_button.visible = false
	close_button.visible = false
	text_label.visible = false
	note_label.visible = false
	label2_label.visible = false

	for lbl in sample_labels:
		lbl.visible = false
	
func _on_dig_pressed() -> void:
	for lbl in sample_labels:
		lbl.visible = false
		
	current_sample_label = sample_labels[randi() % sample_labels.size()]
	
	dig_button.disabled = true
	test_button.disabled = false
	test_button.visible = true
	text_label.visible = true
	label2_label.visible = true

func _on_test_pressed() -> void:
	if current_sample_label == null:
		return
		
	current_sample_label.visible = true
	
	dig_button.disabled = true
	test_button.disabled = true
	test_button.visible = false
	close_button.visible = true
	text_label.visible = false
	note_label.visible = true

func _on_close_pressed() -> void:
	if current_sample_label:
		current_sample_label.visible = false
		
	close_button.visible = false
	dig_button.disabled = false 
	note_label.visible = false
	label2_label.visible = false
