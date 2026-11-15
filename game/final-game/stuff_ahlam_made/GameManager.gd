extends Node

var slot_sample_indices: Dictionary = {}

func has_sample(slot_name: String) -> bool:
	return slot_sample_indices.has(slot_name)

func get_sample(slot_name: String) -> int:
	return slot_sample_indices[slot_name]

func set_sample(slot_name: String, sample_index: int) -> void:
	slot_sample_indices[slot_name] = sample_index

func clear_slot(slot_name: String) -> void:
	if slot_sample_indices.has(slot_name):
		slot_sample_indices.erase(slot_name)
