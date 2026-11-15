extends CanvasLayer

func _ready() -> void:
	hide()

func open_menu() -> void:
	show()

func close_menu() -> void:
	hide()
	queue_free()

func _on_close_menu_pressed() -> void:
	close_menu()

func _on_provide_sample_pressed() -> void:
	if GlobalTracker.global_soil_count >= 3:
		print("Samples accepted!")
	else:
		print("Insufficient samples. You only have: ", GlobalTracker.global_soil_count, "/3")
