extends Control

signal building_selected(source_id: int, tile: Vector2i)
signal delete_selected
@onready var buildmenu = $buildmenu

enum Structure { ROVER = 1, RADIATION = 2, BUTTONTHREE = 3 }
var structure: Structure

func _ready() -> void:
	buildmenu.hide()  # menu starts closed

# the + button (buildmenu2)
func _on_buildmenu_2_pressed() -> void:
	buildmenu.visible = not buildmenu.visible

func _on_building_1_pressed() -> void:
	building_selected.emit(7, Vector2i(36, 9))
	structure = Structure.ROVER
	Rover.rover_built.emit()
	buildmenu.hide()

func _on_building_2_pressed() -> void:
	building_selected.emit(15, Vector2i(8, 1))
	structure = Structure.RADIATION
	Radiation.build_radiation_structure()
	buildmenu.hide()
	
func _on_building_3_pressed() -> void:
	building_selected.emit(2, Vector2i(17, 0))
	structure = Structure.BUTTONTHREE
	buildmenu.hide()

func _on_delete_pressed() -> void:
	delete_selected.emit()
	buildmenu.hide()
