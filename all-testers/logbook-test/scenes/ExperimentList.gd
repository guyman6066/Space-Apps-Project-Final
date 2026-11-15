extends ScrollContainer

enum Mode { DONE, TODO }
@export var mode: Mode = Mode.TODO

const ENTRY := preload("res://experiment_entry.tscn")
@onready var list: VBoxContainer = $List

func _ready() -> void:
	LogbookData.data_changed.connect(refresh)
	refresh()

func refresh() -> void:
	for c in list.get_children():
		c.queue_free()
	if mode == Mode.TODO:
		for e in LogbookData.get_todo():
			_add(e.get("title", ""), e.get("summary", ""), e.get("details", ""))
	else:
		for r in LogbookData.done:
			var def := LogbookData.get_experiment(r.get("id", ""))
			_add(def.get("title", r.get("id", "")), r.get("date", ""), r.get("result", ""))

func _add(title: String, summary: String, body: String) -> void:
	var entry := ENTRY.instantiate()
	list.add_child(entry)
	entry.setup(title, summary, body)
