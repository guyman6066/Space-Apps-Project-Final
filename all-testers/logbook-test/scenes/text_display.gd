extends VBoxContainer

@onready var doing1 = $CurrentlyDoing
@onready var doing2 = $CurrentlyDoing2
@onready var doing3 = $CurrentlyDoing3
@onready var doing4 = $CurrentlyDoing4

var default: String = str("Unoccupied")

func _process(_delta):
	update_text()

func update_text():
	doing1.text = default
	doing2.text = default
	doing3.text = default
	doing4.text = default
