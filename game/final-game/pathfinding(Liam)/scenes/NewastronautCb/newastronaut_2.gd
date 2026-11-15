extends CharacterBody2D

@export var astronaut_index: int = 1

@onready var progress_bar: TextureProgressBar = $TextureProgressBar

@onready var nav2d: NavigationAgent2D = $NavigationAgent2D

@onready var sprite_holder: Node2D = $sprite_holder
@onready var animated_sprite: AnimatedSprite2D = $sprite_holder/AnimatedSprite2D
@onready var sprite: Sprite2D = $sprite_holder/Sprite2D

var speed: float = 100.0

var is_selected: bool = false
var is_moving: bool = false

const ANIMATED_ASTRONAUT_TEXTURES: Array = [
	preload("res://pathfinding(Liam)/assets/Walking_Frames_(BLUE).png"),
	preload("res://pathfinding(Liam)/assets/Walking_frames_(GREEN).png"),
	preload("res://pathfinding(Liam)/assets/Walking_Frames_(YELLOW).png"),
	preload("res://pathfinding(Liam)/assets/Walking_Frames_(RED).png")
]

func update_highlight() -> void:
	if is_selected:
		sprite.modulate = Color(1.3, 1.3, 1.0)
		animated_sprite.modulate = Color(1.3, 1.3, 1.0)
		progress_bar.visible = true
	else:
		sprite.modulate = Color(1.0,1.0, 1.0)
		progress_bar.visible = false
		

func _ready() -> void:
	add_to_group("astronauts_for_button")
	input_pickable = true
	progress_bar.visible = false
	animated_sprite.visible = false
	sprite.visible = true
	
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = not is_selected
		update_highlight()

func _physics_process(_delta: float) -> void:
	manual_navigation()
	#navigate(delta)
	navigate_safe()
	
func manual_navigation() -> void:
	if is_selected and Input.is_action_just_pressed("set_target"):
		nav2d.target_position = get_global_mouse_position()
		is_moving = true
		
		
func navigate(_delta: float) -> void:
	if nav2d.is_navigation_finished():
		return

func navigate_safe() -> void:
	if not is_selected or not is_moving:
		velocity = Vector2.ZERO
		animated_sprite.stop()
		animated_sprite.frame = 0
		animated_sprite.visible = false
		sprite.visible = true
		return
		
	if is_moving and nav2d.is_navigation_finished():
		velocity = Vector2.ZERO
		animated_sprite.stop()
		animated_sprite.frame = 0
		animated_sprite.visible = false
		sprite.visible = true
		is_selected = false
		is_moving = false
		nav2d.target_position = global_position
		update_highlight()
		return
		
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	velocity = (global_position.direction_to(next_path_position) * speed)
	move_and_slide()
	if velocity.length() > 0:
		sprite.visible = false
		animated_sprite.visible = true
		animated_sprite.play("walking(blue)")
		if velocity.x != 0:
			animated_sprite.flip_h = velocity.x < 0
		else:
			animated_sprite.stop()
			animated_sprite.visible = false
			sprite.visible = true
