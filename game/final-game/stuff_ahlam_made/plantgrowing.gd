extends Node2D

@onready var radish_health = $health
@onready var radish_water = $water
@onready var tomato_health = $health3
@onready var tomato_water = $water3
@onready var rye_health = $health2
@onready var rye_water = $water2

@onready var radish_detail = $Radish
@onready var tomato_detail = $Tomato
@onready var rye_detail = $Rye

@onready var radish_label = $Radish2
@onready var radish_button = $Radish2/rakegraphics
@onready var tomato_label = $Tomato2
@onready var tomato_button = $Tomato2/seedsgraphics
@onready var rye_label = $Rye2
@onready var rye_button = $Rye2/showelgraphics

@onready var showel_label = $showel
@onready var showel_button = $showel/showelgraphics
@onready var showeling = $showeling
@onready var seeds_label = $seeds
@onready var seeds_button = $seeds/seedsgraphics
@onready var rake_label = $rake
@onready var rake_button = $rake/rakegraphics
@onready var raking = $raking
@onready var water_label = $wateringcan
@onready var water_button = $wateringcan/watergraphics
@onready var back_label = $back
@onready var back_button = $back/watergraphics
@onready var fertilizer_label = $fertilizer
@onready var fertilizer_button = $fertilizer/fertilizergraphics

@onready var delete_button = $delete

@onready var soilstage = $"soil stage"
@onready var tomatostage1 = $tomatostage1
@onready var tomatostage2 = $tomatostage2
@onready var radishstage1 = $radishstage1
@onready var radishstage2 = $radishstage2

@onready var close_button = $Close
@onready var left_button = $left
@onready var right_button = $right

@onready var slot_label = $slot
@onready var warning_label = $warning
@onready var countdown_label = $countdown
@onready var plantMusicBG: AudioStreamPlayer2D = $PlantGrowing_Audio
var plantBGMusicOn = true

var current_slot: int = 0
const TOTAL_SLOTS: int = 3

enum CropType { EMPTY, RADISH, TOMATO, RYE }

var slot_crop: Array[CropType] = [CropType.EMPTY, CropType.EMPTY, CropType.EMPTY]
var slot_is_showeled: Array[bool] = [false, false, false]

var slot_health: Array[float] = [50.0, 50.0, 50.0]
var slot_water: Array[float] = [50.0, 50.0, 50.0]

var slot_growth_time: Array[float] = [0.0, 0.0, 0.0]

const TIME_TO_STAGE_1: float = 5.0 
const TIME_TO_STAGE_2: float = 10.0 

var is_selecting_seed: bool = false
var is_shoveling: bool = false
var is_raking: bool = false
var is_watering: bool = false
var is_fertilizing: bool = false

const SAVE_FILE_PATH = "user://farm_save.save"

func _ready() -> void:
	load_game()
	update_music()

	if showeling:
		showeling.visible = false
	if raking:
		raking.visible = false

	if left_button and left_button is BaseButton:
		left_button.pressed.connect(_on_left_pressed)
	if right_button and right_button is BaseButton:
		right_button.pressed.connect(_on_right_pressed)
	if seeds_button and seeds_button is BaseButton:
		seeds_button.pressed.connect(_on_seeds_button_pressed)
	if showel_button and showel_button is BaseButton:
		showel_button.pressed.connect(_on_showel_button_pressed)
	if rake_button and rake_button is BaseButton:
		rake_button.pressed.connect(_on_rake_button_pressed)
	if water_button and water_button is BaseButton:
		water_button.pressed.connect(_on_water_button_pressed)
	if fertilizer_button and fertilizer_button is BaseButton:
		fertilizer_button.pressed.connect(_on_fertilizer_button_pressed)
	
	if delete_button and delete_button is BaseButton:
		delete_button.pressed.connect(_on_delete_button_pressed)
		
	if radish_button and radish_button is BaseButton:
		radish_button.pressed.connect(func(): try_plant_crop(CropType.RADISH))
	if tomato_button and tomato_button is BaseButton:
		tomato_button.pressed.connect(func(): try_plant_crop(CropType.TOMATO))
	if rye_button and rye_button is BaseButton:
		rye_button.pressed.connect(func(): try_plant_crop(CropType.RYE))
		
	if warning_label:
		warning_label.text = ""
		warning_label.visible = false
	if countdown_label:
		countdown_label.visible = false
		
	update_slot_system()
	
func update_music():
	if plantBGMusicOn:
		plantMusicBG.play()
	else:
		plantMusicBG.stop()

func _exit_tree() -> void:
	save_game() 

func _process(delta: float) -> void:
	var current_crop = slot_crop[current_slot]
	if current_crop != CropType.EMPTY:
		slot_growth_time[current_slot] += delta
		update_crop_stages(current_crop, slot_growth_time[current_slot])

func is_busy() -> bool:
	return is_shoveling or is_raking or is_watering or is_fertilizing

func _on_left_pressed() -> void:
	if is_busy(): return
	current_slot = (current_slot - 1 + TOTAL_SLOTS) % TOTAL_SLOTS
	is_selecting_seed = false 
	if warning_label: warning_label.visible = false
	update_slot_system()

func _on_right_pressed() -> void:
	if is_busy(): return
	current_slot = (current_slot + 1) % TOTAL_SLOTS
	is_selecting_seed = false 
	if warning_label: warning_label.visible = false
	update_slot_system()

func _on_seeds_button_pressed() -> void:
	if is_busy(): return
	if slot_crop[current_slot] == CropType.EMPTY:
		if not slot_is_showeled[current_slot]:
			if warning_label:
				warning_label.text = "cannot sow seed till showeling is done."
				warning_label.visible = true
			return
		
		if warning_label: warning_label.visible = false
		is_selecting_seed = not is_selecting_seed
		update_slot_system()

func _on_showel_button_pressed() -> void:
	if is_busy() or slot_is_showeled[current_slot]: return
	
	is_shoveling = true
	is_selecting_seed = false
	if warning_label: warning_label.visible = false
	
	showeling.visible = true
	set_buttons_enabled(false)
	
	if countdown_label:
		countdown_label.visible = true
		countdown_label.text = "3"
	
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	slot_is_showeled[current_slot] = true
	is_shoveling = false
	showeling.visible = false
	if countdown_label: countdown_label.visible = false
	
	set_buttons_enabled(true)
	update_slot_system()
	save_game()

func _on_rake_button_pressed() -> void:
	if is_busy(): return
	
	is_raking = true
	is_selecting_seed = false
	if warning_label: warning_label.visible = false
	
	raking.visible = true
	set_buttons_enabled(false)
	
	if countdown_label:
		countdown_label.visible = true
		countdown_label.text = "3"
	
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	is_raking = false
	raking.visible = false
	if countdown_label: countdown_label.visible = false
	
	set_buttons_enabled(true)
	update_slot_system()

func _on_water_button_pressed() -> void:
	if is_busy() or slot_crop[current_slot] == CropType.EMPTY: return
	
	is_watering = true
	is_selecting_seed = false
	if warning_label: warning_label.visible = false
	
	set_buttons_enabled(false)
	if countdown_label:
		countdown_label.visible = true
		countdown_label.text = "3"
	
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	slot_water[current_slot] = min(slot_water[current_slot] + 20.0, 100.0)
	animate_bar_values(slot_health[current_slot], slot_water[current_slot])
	
	is_watering = false
	if countdown_label: countdown_label.visible = false
	
	set_buttons_enabled(true)
	update_slot_system()
	save_game()

func _on_fertilizer_button_pressed() -> void:
	if is_busy() or slot_crop[current_slot] == CropType.EMPTY: return
	
	is_fertilizing = true
	is_selecting_seed = false
	if warning_label: warning_label.visible = false
	
	set_buttons_enabled(false)
	if countdown_label:
		countdown_label.visible = true
		countdown_label.text = "3"
	
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	if countdown_label: countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	slot_health[current_slot] = min(slot_health[current_slot] + 20.0, 100.0)
	animate_bar_values(slot_health[current_slot], slot_water[current_slot])
	
	is_fertilizing = false
	if countdown_label: countdown_label.visible = false
	
	set_buttons_enabled(true)
	update_slot_system()
	save_game()

func _on_delete_button_pressed() -> void:
	if is_busy(): return
	slot_crop[current_slot] = CropType.EMPTY
	slot_is_showeled[current_slot] = false
	slot_health[current_slot] = 50.0
	slot_water[current_slot] = 50.0
	slot_growth_time[current_slot] = 0.0
	is_selecting_seed = false
	
	if warning_label: warning_label.visible = false
	
	update_slot_system()
	save_game()

func try_plant_crop(crop: CropType) -> void:
	if not slot_is_showeled[current_slot]:
		if warning_label:
			warning_label.text = "cannot sow seed till showeling is done."
			warning_label.visible = true
		return
		
	slot_crop[current_slot] = crop
	slot_health[current_slot] = 50.0 
	slot_water[current_slot] = 50.0 
	slot_growth_time[current_slot] = 0.0 
	is_selecting_seed = false
	if warning_label: warning_label.visible = false
	update_slot_system()
	save_game()

func set_buttons_enabled(state: bool) -> void:
	if left_button: left_button.disabled = not state
	if right_button: right_button.disabled = not state
	if seeds_button: seeds_button.disabled = not state
	if showel_button: showel_button.disabled = not state
	if rake_button: rake_button.disabled = not state
	if water_button: water_button.disabled = not state
	if fertilizer_button: fertilizer_button.disabled = not state
	if delete_button: delete_button.disabled = not state
	if close_button: close_button.disabled = not state

func animate_bar_values(target_health: float, target_water: float) -> void:
	var current_crop = slot_crop[current_slot]
	var h_bar = null
	var w_bar = null
	
	match current_crop:
		CropType.RADISH:
			h_bar = radish_health
			w_bar = radish_water
		CropType.TOMATO:
			h_bar = tomato_health
			w_bar = tomato_water
		CropType.RYE:
			h_bar = rye_health
			w_bar = rye_water
	
	var tween = create_tween().set_parallel(true)
	if h_bar and h_bar is Range:
		tween.tween_property(h_bar, "value", target_health, 0.4)
	if w_bar and w_bar is Range:
		tween.tween_property(w_bar, "value", target_water, 0.4)

func update_crop_stages(current_crop: CropType, growth: float) -> void:
	var is_showeled = slot_is_showeled[current_slot]
	
	soilstage.visible = is_showeled and (current_crop == CropType.EMPTY or growth < TIME_TO_STAGE_1)
	
	if current_crop == CropType.RADISH:
		radishstage1.visible = (growth >= TIME_TO_STAGE_1 and growth < TIME_TO_STAGE_2)
		radishstage2.visible = (growth >= TIME_TO_STAGE_2)
	else:
		radishstage1.visible = false
		radishstage2.visible = false
		
	if current_crop == CropType.TOMATO:
		tomatostage1.visible = (growth >= TIME_TO_STAGE_1 and growth < TIME_TO_STAGE_2)
		tomatostage2.visible = (growth >= TIME_TO_STAGE_2)
	else:
		tomatostage1.visible = false
		tomatostage2.visible = false

func update_slot_system() -> void:
	var current_crop = slot_crop[current_slot]
	var has_plant = (current_crop != CropType.EMPTY)
	var is_showeled = slot_is_showeled[current_slot]
	var growth = slot_growth_time[current_slot]
	
	if slot_label:
		slot_label.text = "Slot: " + str(current_slot + 1)
	
	radish_label.visible = (is_selecting_seed and not has_plant)
	radish_button.visible = (is_selecting_seed and not has_plant)
	tomato_label.visible = (is_selecting_seed and not has_plant)
	tomato_button.visible = (is_selecting_seed and not has_plant)
	rye_label.visible = (is_selecting_seed and not has_plant)
	rye_button.visible = (is_selecting_seed and not has_plant)
	
	showel_label.visible = (not has_plant and not is_showeled)
	showel_button.visible = (not has_plant and not is_showeled)
	
	seeds_label.visible = (not has_plant and not is_selecting_seed and is_showeled)
	seeds_button.visible = (not has_plant and not is_selecting_seed and is_showeled)
	
	rake_label.visible = has_plant
	rake_button.visible = has_plant
	water_label.visible = has_plant
	water_button.visible = has_plant
	fertilizer_label.visible = has_plant
	fertilizer_button.visible = has_plant
	
	if delete_button: delete_button.visible = (is_showeled or has_plant)

	if close_button: close_button.visible = true
	
	raking.visible = false
	
	update_crop_stages(current_crop, growth)
	
	var current_h = slot_health[current_slot]
	var current_w = slot_water[current_slot]
	
	radish_health.visible = (current_crop == CropType.RADISH)
	radish_water.visible = (current_crop == CropType.RADISH)
	if current_crop == CropType.RADISH and radish_health is Range:
		radish_health.value = current_h
	if current_crop == CropType.RADISH and radish_water is Range:
		radish_water.value = current_w
	
	tomato_health.visible = (current_crop == CropType.TOMATO)
	tomato_water.visible = (current_crop == CropType.TOMATO)
	if current_crop == CropType.TOMATO and tomato_health is Range:
		tomato_health.value = current_h
	if current_crop == CropType.TOMATO and tomato_water is Range:
		tomato_water.value = current_w
	
	rye_health.visible = (current_crop == CropType.RYE)
	rye_water.visible = (current_crop == CropType.RYE)
	if current_crop == CropType.RYE and rye_health is Range:
		rye_health.value = current_h
	if current_crop == CropType.RYE and rye_water is Range:
		rye_water.value = current_w
	
	if radish_detail: radish_detail.visible = (current_crop == CropType.RADISH)
	if tomato_detail: tomato_detail.visible = (current_crop == CropType.TOMATO)
	if rye_detail: rye_detail.visible = (current_crop == CropType.RYE)

func plant_radish() -> void:
	try_plant_crop(CropType.RADISH)

func plant_tomato() -> void:
	try_plant_crop(CropType.TOMATO)

func plant_rye() -> void:
	try_plant_crop(CropType.RYE)
	
func _on_close_pressed() -> void:
	save_game() 
	SceneManager.change_scene_with_players(
	"res://stuff_ahlam_made/demoplayscreen.tscn",
	[$newastronaut, $newastronaut2, $newastronaut3, $newastronaut4],
	[Vector2(564, 254), Vector2(563, 394), Vector2(654, 254), Vector2(650, 396)]
	)

func save_game() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		return
		
	var save_data = {
		"current_slot": current_slot,
		"slot_crop": slot_crop,
		"slot_is_showeled": slot_is_showeled,
		"slot_health": slot_health,
		"slot_water": slot_water,
		"slot_growth_time": slot_growth_time
	}
	
	var json_string = JSON.stringify(save_data)
	file.store_line(json_string)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
		
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return
		
	var line = file.get_line()
	var json = JSON.new()
	var error = json.parse(line)
	if error == OK:
		var data = json.get_data()
		if typeof(data) == TYPE_DICTIONARY:
			current_slot = data.get("current_slot", 0)
			
			var loaded_crop = data.get("slot_crop", [0, 0, 0])
			for i in range(min(slot_crop.size(), loaded_crop.size())):
				slot_crop[i] = int(loaded_crop[i]) as CropType
				
			var loaded_showeled = data.get("slot_is_showeled", [false, false, false])
			for i in range(min(slot_is_showeled.size(), loaded_showeled.size())):
				slot_is_showeled[i] = bool(loaded_showeled[i])
				
			var loaded_health = data.get("slot_health", [50.0, 50.0, 50.0])
			for i in range(min(slot_health.size(), loaded_health.size())):
				slot_health[i] = float(loaded_health[i])
				
			var loaded_water = data.get("slot_water", [50.0, 50.0, 50.0])
			for i in range(min(slot_water.size(), loaded_water.size())):
				slot_water[i] = float(loaded_water[i])
				
			var loaded_growth = data.get("slot_growth_time", [0.0, 0.0, 0.0])
			for i in range(min(slot_growth_time.size(), loaded_growth.size())):
				slot_growth_time[i] = float(loaded_growth[i])
