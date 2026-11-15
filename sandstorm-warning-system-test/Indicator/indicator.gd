extends CanvasLayer

enum StormState { SAFE, INCOMING, ONGOING }
var current_state: StormState = StormState.SAFE

@export var texture_green: Texture2D
@export var texture_blue: Texture2D
@export var texture_red: Texture2D

@onready var indicator_texture_rect: TextureRect = $TextureRect
@onready var storm_timer: Timer = $Timer

@export var has_detection_tower: bool = false

const DURATION_WITH_TOWER: float = 300.0
const DURATION_WITHOUT_TOWER: float = 30.0

func _ready() -> void:
	storm_timer.timeout.connect(_on_storm_timer_timeout)
	set_state(StormState.SAFE)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and current_state == StormState.SAFE:
		trigger_incoming_storm()
		
func set_state(new_state: StormState) -> void:
	current_state = new_state
	
	match current_state:
		StormState.SAFE:
			indicator_texture_rect.texture = texture_green
			storm_timer.stop()
			print("System Status: SAFE (Green)")
			
		StormState.INCOMING:
			indicator_texture_rect.texture = texture_blue
			var duration = DURATION_WITH_TOWER if has_detection_tower else DURATION_WITHOUT_TOWER
			storm_timer.start(duration)
			print("System Status: INCOMING STORM (Blue). Timer set to: ", duration, " seconds.")
			
		StormState.ONGOING:
			indicator_texture_rect.texture = texture_red
			storm_timer.stop()
			print("System Status: SANDSTORM ONGOING (Red)")
			
func trigger_incoming_storm() -> void:
	if current_state == StormState.SAFE:
		set_state(StormState.INCOMING)
		
func _on_storm_timer_timeout() -> void:
	if current_state == StormState.INCOMING:
		set_state(StormState.ONGOING)
			
			
			
