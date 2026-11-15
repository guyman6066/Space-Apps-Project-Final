extends Node

var slot_sample_indices: Dictionary = {}

func clear_slot(slot_name: String) -> void:
	if slot_sample_indices.has(slot_name):
		slot_sample_indices.erase(slot_name)
