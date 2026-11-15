extends Node2D

@onready var showel = $showel
@onready var rake = $rake
@onready var seeds = $seeds
@onready var wateringcan = $wateringcan
@onready var fertilizer = $fertilizer
@onready var back = $back
@onready var tomato = $Tomato
@onready var Rye = $Rye
@onready var Radish = $Radish

@export var tomato_data: SeedData
@export var rye_data: SeedData
@export var radish_data: SeedData

@export var plant_scene: PackedScene # Assign a scene containing Plant.gd

@onready var name_input: LineEdit = $UI/NameInput
@onready var status_label: Label = $UI/StatusLabel

var current_plant: Plant = null
var selected_seed_data: SeedData

func _ready() -> void:
	showel.visible = true 
	rake.visible = true 
	seeds.visible = true 
	wateringcan.visible = true 
	fertilizer.visible = true 
	back.visible = false
	tomato.visible = false
	Rye.visible = false
	Radish.visible = false
	selected_seed_data = tomato_data
	update_seed_selection_visuals()

func _process(delta: float) -> void:
	pass

func _on_seedsgraphics_pressed() -> void:
	showel.visible = false
	rake.visible = false
	seeds.visible = false
	wateringcan.visible = false
	fertilizer.visible = false
	back.visible = true
	
	# Show labels and highlight based on current selection
	update_seed_selection_visuals()

func _on_select_tomato_pressed() -> void:
	selected_seed_data = tomato_data
	update_seed_selection_visuals()

func _on_select_rye_pressed() -> void:
	selected_seed_data = rye_data
	update_seed_selection_visuals()

func _on_select_radish_pressed() -> void:
	selected_seed_data = radish_data
	update_seed_selection_visuals()

func update_seed_selection_visuals() -> void:
	if back.visible:
		tomato.visible = (selected_seed_data == tomato_data)
		Rye.visible = (selected_seed_data == rye_data)
		Radish.visible = (selected_seed_data == radish_data)
	else:
		tomato.visible = false
		Rye.visible = false
		Radish.visible = false

func _on_showel_button_pressed() -> void:
	if current_plant != null:
		current_plant.queue_free()
		
	if plant_scene and selected_seed_data:
		var new_plant = plant_scene.instantiate() as Plant
		add_child(new_plant)
	
		var custom_name = name_input.text
		new_plant.setup_plant(selected_seed_data, custom_name)
		
		new_plant.status_changed.connect(_on_plant_status_changed)
		current_plant = new_plant
		
		_on_plant_status_changed(current_plant.get_status())

func _on_water_button_pressed() -> void:
	if current_plant:
		current_plant.water_plant(30.0)

func _on_fertilizer_button_pressed() -> void:
	if current_plant:
		current_plant.health = min(100.0, current_plant.health + 25.0)
		current_plant.growth_progress += 2.0 
		current_plant.status_changed.emit(current_plant.get_status())

func _on_plant_status_changed(info: Dictionary) -> void:
	status_label.text = "Name: %s (%s)\nHealth: %.1f%%\nHydration: %.1f%%\nStage: %d/%d" % [
		info["name"],
		info["type"],
		info["health"],
		info["hydration"],
		info["stage"],
		info["max_stages"]
	]

func _on_back_pressed() -> void:
	showel.visible = true 
	rake.visible = true 
	seeds.visible = true 
	wateringcan.visible = true 
	fertilizer.visible = true 
	back.visible = false
	tomato.visible = false
	Rye.visible = false
	Radish.visible = false
