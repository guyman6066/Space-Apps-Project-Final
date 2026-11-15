extends Node

signal data_changed

const EXPERIMENTS_PATH := "res://data/experiments.json"
const DONE_PATH := "user://experiments_done.json"
const GUIDE_PATH := "res://data/guidebook.txt"

var experiments: Array = []
var done: Array = []

func _ready() -> void:
	experiments = _load_json(EXPERIMENTS_PATH)
	done = _load_json(DONE_PATH)

func _load_json(path: String) -> Array:
	if not FileAccess.file_exists(path):
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Array else []

func get_experiment(id: String) -> Dictionary:
	for e in experiments:
		if e.get("id") == id:
			return e
	return {}

func is_done(id: String) -> bool:
	return done.any(func(r): return r.get("id") == id)

func get_todo() -> Array:
	return experiments.filter(func(e): return not is_done(e.get("id", "")))

# Call this from your game when an experiment finishes
func complete_experiment(id: String, result: String) -> void:
	if is_done(id):
		return
	done.append({
		"id": id,
		"date": Time.get_datetime_string_from_system(false, true),
		"result": result,
	})
	var f := FileAccess.open(DONE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(done, "\t"))
	data_changed.emit()
