extends CanvasLayer

enum StormState { SAFE, INCOMING, ONGOING }
var current_state: StormState = StormState.SAFE

@export var texture_green: Texture2D
@export var texture_blue: Texture2D
@export var texture_red: Texture2D

@onready var indicator_texture_rect: TextureRect = $DeviceTextureRect
@onready var storm_timer: Timer = $SandstormTimer
@onready var musicAudioStreamBG: AudioStreamPlayer2D =$"../SandStorm_Audio" 
var backgroundMusicOn = true

@export var has_detection_tower: bool = false

const DURATION_WITH_TOWER: float = 300.0
const DURATION_WITHOUT_TOWER: float = 30.0

# Randomized timings (in seconds)
@export var safe_time_min: float = 120.0   # earliest a storm can start after SAFE begins
@export var safe_time_max: float = 360.0   # latest
@export var storm_time_min: float = 120.0  # 2 minutes
@export var storm_time_max: float = 180.0  # 3 minutes

func _ready() -> void:
	storm_timer.one_shot = true
	storm_timer.timeout.connect(_on_storm_timer_timeout)
	set_state(StormState.SAFE)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and current_state == StormState.SAFE:
		trigger_incoming_storm()
		
func update_music():
	if backgroundMusicOn:
		if current_state == StormState.ONGOING:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()
		
func set_state(new_state: StormState) -> void:
	current_state = new_state
	
	match current_state:
		StormState.SAFE:
			indicator_texture_rect.texture = texture_green
			var wait = randf_range(safe_time_min, safe_time_max)
			storm_timer.start(wait)
			print("System Status: SAFE (Green). Next storm warning in: ", snapped(wait, 0.1), " seconds.")
			
		StormState.INCOMING:
			indicator_texture_rect.texture = texture_blue
			var duration = DURATION_WITH_TOWER if has_detection_tower else DURATION_WITHOUT_TOWER
			storm_timer.start(duration)
			print("System Status: INCOMING STORM (Blue). Timer set to: ", duration, " seconds.")
			
		StormState.ONGOING:
			indicator_texture_rect.texture = texture_red
			update_music()
			var storm_length = randf_range(storm_time_min, storm_time_max)
			storm_timer.start(storm_length)
			print("System Status: SANDSTORM ONGOING (Red). Lasts: ", snapped(storm_length, 0.1), " seconds.")
			
func trigger_incoming_storm() -> void:
	if current_state == StormState.SAFE:
		set_state(StormState.INCOMING)
		
func _on_storm_timer_timeout() -> void:
	match current_state:
		StormState.SAFE:
			set_state(StormState.INCOMING)
		StormState.INCOMING:
			set_state(StormState.ONGOING)
		StormState.ONGOING:
			set_state(StormState.SAFE)
			
			
			
