extends Control

const SAVE_PATHS = {
	1: "user://save_slot_1.json",
	2: "user://save_slot_2.json",
	3: "user://save_slot_3.json"
}

@onready var game_node = get_node_or_null("../MainMenu")  

@onready var slot1 = get_node_or_null("slot1")
@onready var slot2 = get_node_or_null("slot2")
@onready var slot3 = get_node_or_null("slot3")

@onready var delete1_button = get_node_or_null("delete1")
@onready var delete2_button = get_node_or_null("delete2")
@onready var delete3_button = get_node_or_null("delete3")

@onready var backtomain = get_node_or_null("Back")
@onready var edit = get_node_or_null("edit")
@onready var backtoscreen = get_node_or_null("back2") 

func _ready() -> void:
	if not backtoscreen:
		print("WARNING: 'Back2' node was not found! Check your Scene tree node name.")
	
	set_edit_mode(false)

	if slot1 and not slot1.pressed.is_connected(_on_slot_pressed):
		slot1.pressed.connect(func(): _on_slot_pressed(1))
	if slot2 and not slot2.pressed.is_connected(_on_slot_pressed):
		slot2.pressed.connect(func(): _on_slot_pressed(2))
	if slot3 and not slot3.pressed.is_connected(_on_slot_pressed):
		slot3.pressed.connect(func(): _on_slot_pressed(3))
		
	if delete1_button and not delete1_button.pressed.is_connected(delete_save):
		delete1_button.pressed.connect(func(): delete_save(1))
	if delete2_button and not delete2_button.pressed.is_connected(delete_save):
		delete2_button.pressed.connect(func(): delete_save(2))
	if delete3_button and not delete3_button.pressed.is_connected(delete_save):
		delete3_button.pressed.connect(func(): delete_save(3))

	if backtomain and not backtomain.pressed.is_connected(_on_back_pressed):
		backtomain.pressed.connect(_on_back_pressed)
	if edit and not edit.pressed.is_connected(_on_edit_pressed):
		edit.pressed.connect(_on_edit_pressed)
	if backtoscreen and not backtoscreen.pressed.is_connected(_on_back_2_pressed):
		backtoscreen.pressed.connect(_on_back_2_pressed)

func _on_slot_pressed(slot_number: int) -> void:
	var file_path = SAVE_PATHS[slot_number]
	
	if FileAccess.file_exists(file_path):
		print("Save found in Slot ", slot_number, ". Loading game...")
		load_game_from_slot(slot_number)
	else:
		print("Slot ", slot_number, " is empty. Saving current game...")
		save_game_to_slot(slot_number)

func save_game_to_slot(slot_number: int) -> void:
	var file_path = SAVE_PATHS[slot_number]
	var game_data = get_current_game_data()
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(game_data)
		file.store_string(json_string)
		print("Successfully saved game to slot: ", slot_number)
	else:
		print("Error: Could not write to save path: ", file_path)

func load_game_from_slot(slot_number: int) -> void:
	var file_path = SAVE_PATHS[slot_number]
	if not FileAccess.file_exists(file_path):
		print("No save file found in slot: ", slot_number)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			var loaded_data = json.get_data()
			apply_loaded_data(loaded_data)
		else:
			print("JSON Parse Error: ", json.get_error_message())

func delete_save(slot_number: int) -> void:
	var file_path = SAVE_PATHS[slot_number]
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("Successfully deleted save in slot: ", slot_number)
		else:
			print("Failed to delete save file in slot: ", slot_number)
	else:
		print("No save file exists to delete in slot: ", slot_number)

func get_current_game_data() -> Dictionary:
	if game_node:
		return {
			"total_food": game_node.get("total_food") if "total_food" in game_node else 100.0,
			"total_water": game_node.get("total_water") if "total_water" in game_node else 100.0,
			"total_oxygen": game_node.get("total_oxygen") if "total_oxygen" in game_node else 100.0,
			"timer": game_node.get("timer") if "timer" in game_node else 0.0,
			"characters": game_node.get("characters") if "characters" in game_node else []
		}
	
	return {
		"total_food": 100.0,
		"total_water": 100.0,
		"total_oxygen": 100.0,
		"timer": 0.0,
		"characters": []
	}

func apply_loaded_data(loaded_data: Dictionary) -> void:
	if game_node:
		game_node.total_food = loaded_data.get("total_food", 100.0)
		game_node.total_water = loaded_data.get("total_water", 100.0)
		game_node.total_oxygen = loaded_data.get("total_oxygen", 100.0)
		game_node.timer = loaded_data.get("timer", 0.0)
		game_node.characters = loaded_data.get("characters", [])
		
		if game_node.has_method("update_all_ui"):
			game_node.update_all_ui()
		print("Game data successfully applied!")

func set_edit_mode(enabled: bool) -> void:
	if delete1_button: delete1_button.visible = enabled
	if delete2_button: delete2_button.visible = enabled
	if delete3_button: delete3_button.visible = enabled
	if backtomain: backtomain.visible = not enabled
	if edit: edit.visible = not enabled
	if backtoscreen: backtoscreen.visible = enabled

func _on_back_pressed() -> void:
	print("Back Pressed")
	get_tree().change_scene_to_file('res://MainMenu.tscn')

func _on_edit_pressed() -> void:
	set_edit_mode(true)
	slot1.visible = false
	slot2.visible = false
	slot3.visible = false
	
func _on_back_2_pressed() -> void:
	set_edit_mode(false)
	slot1.visible = true
	slot2.visible = true
	slot3.visible = true
