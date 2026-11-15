extends Node

signal stats_changed

# Array tracking 4 characters, each with Health, Water, and Oxygen
var characters: Array = [
	{"name": "Char 1", "health": 100.0, "max_health": 100.0, "water": 100.0, "max_water": 100.0, "oxygen": 100.0, "max_oxygen": 100.0},
	{"name": "Char 2", "health": 100.0, "max_health": 100.0, "water": 100.0, "max_water": 100.0, "oxygen": 100.0, "max_oxygen": 100.0},
	{"name": "Char 3", "health": 100.0, "max_health": 100.0, "water": 100.0, "max_water": 100.0, "oxygen": 100.0, "max_oxygen": 100.0},
	{"name": "Char 4", "health": 100.0, "max_health": 100.0, "water": 100.0, "max_water": 100.0, "oxygen": 100.0, "max_oxygen": 100.0}
]

# Overall shared resource pool
var global_food: float = 100.0
var global_water: float = 100.0
var max_resource: float = 100.0

func _process(delta: float) -> void:
	consume_global_resources(0.2 * delta, 0.4 * delta)
	
	for i in range(characters.size()):
		drain_individual_stats(i, 0.5 * delta, 1.0 * delta)

func consume_global_resources(food_amount: float, water_amount: float) -> void:
	global_food = clamp(global_food - food_amount, 0.0, max_resource)
	global_water = clamp(global_water - water_amount, 0.0, max_resource)
	stats_changed.emit()

func drain_individual_stats(index: int, water_drain: float, oxygen_drain: float) -> void:
	characters[index].water = clamp(characters[index].water - water_drain, 0.0, characters[index].max_water)
	characters[index].oxygen = clamp(characters[index].oxygen - oxygen_drain, 0.0, characters[index].max_oxygen)
	
	if characters[index].oxygen <= 0 or characters[index].water <= 0:
		damage_character(index, 5.0 * get_process_delta_time())
	else:
		stats_changed.emit()

func damage_character(index: int, amount: float) -> void:
	characters[index].health = clamp(characters[index].health - amount, 0.0, characters[index].max_health)
	stats_changed.emit()
	check_game_over(index)

func check_game_over(index: int) -> void:

	if characters[index].health <= 0:
		get_tree().change_scene_to_file("")
