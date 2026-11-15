extends Node2D

var selected_tube: Button = null
var current_sample_label: Label = null

@onready var character_one: Node2D = $ON
@onready var character_two: Node2D = $OFF
@onready var acc_character: Node2D = $Red
@onready var washroom_label: Label = $washroomcountdown
@onready var bg_label: Label = $bg
@onready var testingspace_label: Label = $testingspace
@onready var button2_button: Button = $Panel/ble
@onready var button3_button: Button = $Panel/blu
@onready var soil_button: Button = $Panel/soil
@onready var expirement_label: Label = $Panel/expirement
@onready var left_button: Button = $Left
@onready var right_button: Button = $Right
@onready var close_button: Button = $Close
@onready var washroom2_button: Button = $washroom
@onready var close2_button: Button = $Close2
@onready var h_scrollbar: HScrollBar = $HScrollBar
@onready var note_label: Label = $note
@onready var test_button: Button = $test
@onready var select_label: Label = $select
@onready var h2_panel: Panel = $Panel2
@onready var h_panel: Panel = $Panel
@onready var workingbench_button: Button = $workingbench

@onready var sample_labels: Array[Label] = [
	$PanelContainer/sample1,
	$PanelContainer/sample2,
	$PanelContainer/sample3
]

@onready var testtubes_buttons: Array[Button] = [
	$HScrollBar/Sample1,
	$HScrollBar/Sample2,
	$HScrollBar/Sample3,
	$HScrollBar/Sample4,
	$HScrollBar/Sample5,
	$HScrollBar/Sample6,
	$HScrollBar/Sample7,
	$HScrollBar/Sample8,
]

func _ready() -> void:
	var current_scene_file = get_tree().current_scene.scene_file_path.get_file().get_basename().to_lower()
	if current_scene_file == "demoplayscreen":
		set_character_active(character_one, true)
		set_character_active(character_two, false)
	else:
		set_character_active(character_one, false)
		set_character_active(character_two, true)
		
	bg_label.visible = false
	testingspace_label.visible = false
	if button2_button: button2_button.visible = false
	if button3_button: button3_button.visible = false
	if soil_button: soil_button.visible = false
	if expirement_label: expirement_label.visible = false
	if close2_button: close2_button.visible = false
	if h_scrollbar: h_scrollbar.visible = false
	if test_button: test_button.visible = false
	if note_label: note_label.visible = false
	if select_label: select_label.visible = false
	h_panel.visible = false
	if h2_panel: h2_panel.visible = false

	for btn in testtubes_buttons:
		if btn:
			btn.pressed.connect(_on_test_tube_pressed.bind(btn))
			
	if test_button:
		test_button.pressed.connect(_on_test_pressed)

	for lbl in sample_labels:
		if lbl:
			lbl.visible = false

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
	if acc_character: acc_character.visible = false
	if washroom_label: washroom_label.visible = true
	for i in range(5, 0, -1):
		washroom_label.text = "Returning in %ds..." % i
		await get_tree().create_timer(1.0).timeout
	washroom_label.visible = false
	washroom_label.text = ""
	if acc_character: acc_character.visible = true

func _on_soil_pressed() -> void:
	h_scrollbar.visible = true
	test_button.visible = true
	test_button.disabled = false
	note_label.visible = false
	select_label.visible = true
	select_label.text = "Select a test tube, then click test."
	bg_label.visible = true
	testingspace_label.visible = true
	if button2_button: button2_button.visible = false
	if button3_button: button3_button.visible = false
	if soil_button: soil_button.visible = false
	if expirement_label: expirement_label.visible = false
	if close2_button: close2_button.visible = true
	h_panel.visible = false
	if h2_panel: h2_panel.visible = false
	washroom2_button.disabled = true
	left_button.disabled = true
	right_button.disabled = true
	close_button.disabled = true

func _on_workingbench_pressed() -> void:
	bg_label.visible = true
	testingspace_label.visible = true
	if button2_button: button2_button.visible = true
	if button3_button: button3_button.visible = true
	if soil_button: soil_button.visible = true
	if expirement_label: expirement_label.visible = true
	if close2_button: close2_button.visible = true
	if select_label: select_label.visible = false
	h_panel.visible = false
	if h2_panel: h2_panel.visible = true
	washroom2_button.disabled = true
	left_button.disabled = true
	right_button.disabled = true
	close_button.disabled = true
	workingbench_button.disabled = true
	
func _on_close_2_pressed() -> void:
	if current_sample_label:
		current_sample_label.visible = false
	bg_label.visible = false
	testingspace_label.visible = false
	if button2_button: button2_button.visible = false
	if button3_button: button3_button.visible = false
	if soil_button: soil_button.visible = false
	if expirement_label: expirement_label.visible = false
	if close_button: close_button.disabled = false
	if h_scrollbar: h_scrollbar.visible = false
	if test_button: test_button.visible = false
	if note_label: note_label.visible = false
	if select_label: select_label.visible = false
	h_panel.visible = false
	if h2_panel: h2_panel.visible = false
	washroom2_button.disabled = false
	left_button.disabled = false
	right_button.disabled = false
	selected_tube = null
	current_sample_label = null
	workingbench_button.disabled = false
	close2_button.visible = false
	
func _on_test_tube_pressed(button: Button) -> void:
	selected_tube = button
	
	# Check GameManager: If this test tube doesn't have a sample index saved yet, generate one randomly (0, 1, or 2)
	if not GameManager.slot_sample_indices.has(button.name):
		var random_index = randi() % sample_labels.size()
		GameManager.slot_sample_indices[button.name] = random_index
		print("Generated & saved sample for ", button.name, " -> Type Index: ", random_index)
	
	var assigned_sample = GameManager.slot_sample_indices[button.name]
	if select_label:
		select_label.text = "Selected: " + button.name + " (Sample #" + str(assigned_sample + 1) + "). Click Test!"

func _on_test_pressed() -> void:
	if selected_tube == null:
		if select_label:
			select_label.text = "Please select a test tube first!"
		return
		
	for lbl in sample_labels:
		if lbl:
			lbl.visible = false

	# Look up the saved index from GameManager using the button's name
	if GameManager.slot_sample_indices.has(selected_tube.name):
		var sample_index = GameManager.slot_sample_indices[selected_tube.name]
		if sample_index >= 0 and sample_index < sample_labels.size():
			current_sample_label = sample_labels[sample_index]
		else:
			current_sample_label = null
	else:
		current_sample_label = null
		
	if current_sample_label == null:
		if select_label:
			select_label.visible = true
			select_label.text = "No sample found in this tube."
		return
		
	current_sample_label.visible = true
	h_scrollbar.visible = false
	test_button.visible = false
	note_label.visible = true
	select_label.visible = false
	bg_label.visible = true
	testingspace_label.visible = true
	if button2_button: button2_button.visible = false
	if button3_button: button3_button.visible = false
	if soil_button: soil_button.visible = false
	if expirement_label: expirement_label.visible = false
	washroom2_button.disabled = true
	left_button.disabled = true
	right_button.disabled = true
	close_button.disabled = true
	close2_button.visible = true
	h_panel.visible = false
	h2_panel.visible = true
