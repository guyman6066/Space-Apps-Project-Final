extends CharacterBody2D

signal health_changed(new_health: float)

var max_health: float = 100.0
var current_health: float = max_health

func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = clamp(current_health, 0.0, max_health)
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	get_tree().reload_current_scene()
