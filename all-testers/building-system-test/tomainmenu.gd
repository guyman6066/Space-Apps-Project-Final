extends Control

signal building_selected(source_id: int, tile: Vector2i)
signal delete_selected

@onready var buildmenu = $buildmenu

func _ready() -> void:
	buildmenu.hide()  # menu starts closed

# the + button (buildmenu2)
func _on_buildmenu_2_pressed() -> void:
	buildmenu.visible = not buildmenu.visible

func _on_building_1_pressed() -> void:
	building_selected.emit(2, Vector2i(12, 6))
	buildmenu.hide()

func _on_building_2_pressed() -> void:
	building_selected.emit(2, Vector2i(11, 3))
	buildmenu.hide()

func _on_building_3_pressed() -> void:
	building_selected.emit(2, Vector2i(17, 0))
	buildmenu.hide()

func _on_delete_pressed() -> void:
	delete_selected.emit()
	buildmenu.hide()
