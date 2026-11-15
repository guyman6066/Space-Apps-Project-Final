extends Control

var total_food: float = 100.0   
var total_water: float = 100.0  
var total_oxygen: float = 100.0 

@export var quarter_sol_duration: float = 21600.0 # 6 hours in seconds
var timer: float = 0.0
var is_in_sandstorm: bool = false
var is_in_spaceship: bool = false 

func set_in_spaceship(in_spaceship: bool) -> void:
	is_in_spaceship = in_spaceship

var characters: Array[Dictionary] = [
	{"name": "Astronaut 1", "health": 80.0, "water": 60.0, "is_eating": false, "is_drinking": false},
	{"name": "Astronaut 2", "health": 100.0, "water": 90.0, "is_eating": false, "is_drinking": false},
	{"name": "Astronaut 3", "health": 50.0, "water": 40.0, "is_eating": false, "is_drinking": false},
	{"name": "Astronaut 4", "health": 90.0, "water": 75.0, "is_eating": false, "is_drinking": false}
]

@onready var top_oxygen_bar: TextureProgressBar = $VBoxContainer/O2
@onready var top_food_bar: TextureProgressBar = $VBoxContainer/Food
@onready var top_water_bar: TextureProgressBar = $VBoxContainer/H2O

func _ready() -> void:
	setup_character_buttons()
	update_all_ui()

func _process(delta: float) -> void:
	timer += delta
	if timer >= quarter_sol_duration:
		timer = 0.0
		decrease_food_supply()
	
	if not is_in_spaceship:
		total_oxygen = max(0.0, total_oxygen - (0.005 * delta))
		update_all_ui()

	if is_in_sandstorm:
		apply_sandstorm_damage(delta)
		
func _on_enter_spaceship_pressed() -> void:
	set_in_spaceship(true)
	print("Entered the spaceship. Oxygen consumption paused!")

func _on_exit_spaceship_pressed() -> void:
	set_in_spaceship(false)
	print("Stepped outside onto Mars. Oxygen depleting!")
		
func setup_character_buttons() -> void:
	for i in range(4):
		var index_str = str(i + 1)
		
		var feed_btn: Button = get_node_or_null("Feed" + index_str)
		var drink_btn: Button = get_node_or_null("Drink" + index_str)

		print("Character ", index_str, " -> Feed found? ", feed_btn != null, " | Drink found? ", drink_btn != null)

		if feed_btn and not feed_btn.pressed.is_connected(_on_feed_pressed):
			feed_btn.pressed.connect(_on_feed_pressed.bind(i))
			
		if drink_btn and not drink_btn.pressed.is_connected(_on_drink_pressed):
			drink_btn.pressed.connect(_on_drink_pressed.bind(i))

func _on_feed_pressed(char_index: int) -> void:
	var char_data = characters[char_index]
	if char_data["health"] >= 100.0 or char_data["is_eating"] or total_food < 5.0:
		return

	char_data["is_eating"] = true
	total_food -= 5.0
	update_all_ui()

	await get_tree().create_timer(1.5).timeout

	char_data["health"] = min(100.0, char_data["health"] + 15.0)
	char_data["is_eating"] = false
	update_all_ui()

func _on_drink_pressed(char_index: int) -> void:
	var char_data = characters[char_index]
	if char_data["water"] >= 100.0 or char_data["is_drinking"] or total_water < 5.0:
		return

	char_data["is_drinking"] = true
	total_water -= 5.0
	update_all_ui()

	await get_tree().create_timer(1.5).timeout

	char_data["water"] = min(100.0, char_data["water"] + 25.0)
	char_data["health"] = min(100.0, char_data["health"] + 5.0)
	char_data["is_drinking"] = false
	update_all_ui()

func decrease_food_supply() -> void:
	total_food = max(0.0, total_food - 3.0)
	update_all_ui()
	
func decrease_oxygen_supply() -> void:
	total_oxygen = max(0.0, total_oxygen - 4.0)
	update_all_ui()

func apply_sandstorm_damage(delta: float) -> void:
	for character in characters:
		character["health"] = max(0.0, character["health"] - (2.0 * delta))
	update_all_ui()

func set_sandstorm(active: bool) -> void:
	is_in_sandstorm = active

func update_all_ui() -> void:
	if top_food_bar: top_food_bar.value = total_food
	if top_water_bar: top_water_bar.value = total_water
	if top_oxygen_bar: top_oxygen_bar.value = total_oxygen

	for i in range(4):
		var index_str = str(i + 1)
		var char_data = characters[i]

		var card = get_node_or_null("Character" + index_str)
		if card:
			var health_bar = card.get_child(0) as Range
			var water_bar = card.get_child(1) as Range

			if health_bar: health_bar.value = char_data["health"]
			if water_bar: water_bar.value = char_data["water"]

		var feed_btn: Button = get_node_or_null("Feed" + index_str)
		var feeding_btn: Button = get_node_or_null("Feeding" + index_str)
		var drink_btn: Button = get_node_or_null("Drink" + index_str)
		var drinking_btn: Button = get_node_or_null("Drinking" + index_str)

		if feed_btn and feeding_btn:
			if char_data["is_eating"]:
				feed_btn.visible = false
				feeding_btn.visible = true
			else:
				feed_btn.visible = true
				feeding_btn.visible = false
				feed_btn.disabled = (char_data["health"] >= 100.0) or (total_food < 5.0)

		if drink_btn and drinking_btn:
			if char_data["is_drinking"]:
				drink_btn.visible = false
				drinking_btn.visible = true
			else:
				drink_btn.visible = true
				drinking_btn.visible = false
				drink_btn.disabled = (char_data["water"] >= 100.0) or (total_water < 5.0)

	check_game_over()

func check_game_over() -> void:
	for character in characters:
		if character["health"] <= 0.0:
			print(character["name"], " has died. Triggering game over!")
			get_tree().change_scene_to_file("res://Gameoverscreen.tscn")
			return
