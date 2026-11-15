class_name Plant
extends Node2D

signal status_changed(info: Dictionary)

var seed_data: SeedData
var custom_name: String = ""
var health: float = 100.0
var hydration: float = 100.0
var current_stage: int = 0
var growth_progress: float = 0.0
var max_stages: int = 2

func setup_plant(data: SeedData, p_name: String) -> void:
	seed_data = data
	custom_name = p_name
	health = 100.0
	hydration = 100.0
	current_stage = 0
	growth_progress = 0.0

func water_plant(amount: float) -> void:
	hydration = min(100.0, hydration + amount)
	status_changed.emit(get_status())

func get_status() -> Dictionary:
	return {
		"name": custom_name,
		"type": seed_data.plant_name if seed_data else "Unknown",
		"health": health,
		"hydration": hydration,
		"stage": current_stage,
		"max_stages": max_stages
	}
