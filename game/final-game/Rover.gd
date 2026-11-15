extends Node

signal rover_built
signal rover_destroyed

var rover := false

func build_rover() -> void:
	rover = true
	rover_built.emit()
	
func destroy_rover() -> void:
	rover = false
	rover_destroyed.emit()
