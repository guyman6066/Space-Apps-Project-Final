extends MarginContainer

@export var menu_screen: HBoxContainer
@export var open_menu_screen: HBoxContainer
@onready var week = $"../../Node/Control/week"
@onready var date = $"../../Node/Control/date"

func _ready() -> void:
	set_open(false)

func set_open(open: bool) -> void:
	menu_screen.visible = open
	open_menu_screen.visible = not open
	week.visible = not open
	date.visible = not open
	

func _on_toggle_menu_button_pressed() -> void:
	set_open(not menu_screen.visible)
	
