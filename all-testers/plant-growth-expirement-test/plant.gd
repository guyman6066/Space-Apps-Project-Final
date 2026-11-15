class_name Plant
extends Node2D

signal status_changed(plant_info: Dictionary)

var custom_name: String = ""
var seed_data: SeedData

var hydration: float = 100.0
var health: float = 100.0
var current_stage: int = 0
var growth_progress: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

func setup_plant(data: SeedData, given_name: String) -> void:
	seed_data = data
	custom_name = given_name if given_name != "" else seed_data.plant_name
	
	if seed_data.frames.size() > 0:
		sprite.texture = seed_data.frames[0]
		
	timer.wait_time = 1.0
	timer.timeout.connect(_on_tick)
	timer.start()

func _process(delta: float) -> void:
	if seed_data == null:
		return
		
	if current_stage < seed_data.frames.size() - 1 and health > 20.0:
		growth_progress += delta
		if growth_progress >= seed_data.growth_time_per_stage:
			growth_progress = 0.0
			advance_stage()

func _on_tick() -> void:
	if seed_data == null:
		return
		
	hydration = max(0.0, hydration - seed_data.water_decay_rate)
	
	if hydration <= 0.0:
		health = max(0.0, health - seed_data.health_decay_rate)
	elif hydration > 50.0 and health < 100.0:
		health = min(100.0, health + 2.0)
		
	status_changed.emit(get_status())

func water_plant(amount: float = 30.0) -> void:
	hydration = min(100.0, hydration + amount)
	status_changed.emit(get_status())

func advance_stage() -> void:
	current_stage += 1
	if current_stage < seed_data.frames.size():
		sprite.texture = seed_data.frames[current_stage]
	status_changed.emit(get_status())

func get_status() -> Dictionary:
	return {
		"name": custom_name,
		"type": seed_data.plant_name if seed_data else "Unknown",
		"hydration": hydration,
		"health": health,
		"stage": current_stage + 1,
		"max_stages": seed_data.frames.size() if seed_data else 0,
		"is_fully_grown": current_stage >= (seed_data.frames.size() - 1) if seed_data else false
	}
