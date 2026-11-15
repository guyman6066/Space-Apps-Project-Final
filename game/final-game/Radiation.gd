extends Node

signal radiation_measure_center_built

var is_structure_built: bool = false

func build_radiation_structure():
	is_structure_built = true
	radiation_measure_center_built.emit()
