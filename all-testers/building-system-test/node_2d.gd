extends Node2D

# Seconds a building takes to construct. Editable in the Inspector.
@export var build_time : float = 5.0

# Build time per building, keyed by its atlas coordinates.
# Anything not listed here falls back to build_time above.
var build_times : Dictionary = {
	Vector2i(12, 6): 3.0,   # Building 1
	Vector2i(11, 3): 5.0,   # Building 2
	Vector2i(17, 0): 10.0,  # Building 3
}

@onready var ground = $Ground
@onready var preview = $Preview

var source_id : int
var selected_tile : Vector2i

var select_mode : bool = false
var delete_mode : bool = false

# Delete mode hover state
var hovered_structure : Array = []  # footprint cells, passed to remove_structure
var hovered_origin : Vector2i
var has_hovered : bool = false

# Every finished building, keyed by its placement (origin) tile.
# Delete mode uses this to find the building under the mouse by its visible area.
var structures : Dictionary = {}  # Vector2i -> {"src": int, "atlas": Vector2i}

# Translucent buildings that are currently under construction
var construction : TileMapLayer
# Tiles reserved by buildings under construction
var reserved_tiles : Dictionary = {}


var preview_tile : Vector2i:
	set(value):
		if preview_tile == value:
			return
		preview.erase_cell(preview_tile)
		preview_tile = value
		preview.set_cell(value, source_id, selected_tile)
		_update_placeable()


var placeable : bool = true:
	set(value):
		placeable = value
		preview.modulate = Color.RED if not value else Color("ffffff6f")


var removable : bool = false:
	set(value):
		removable = value
		preview.modulate = Color.RED if value else Color("ffffff6f")


func _ready() -> void:
	# Menu buttons
	$CanvasLayer/pausemenu.building_selected.connect(_enter_select_mode)
	$CanvasLayer/pausemenu.delete_selected.connect(_enter_delete_mode)

	# Layer that holds the translucent buildings while they're being built
	construction = TileMapLayer.new()
	construction.tile_set = ground.tile_set
	construction.transform = ground.transform  # same position/scale/rotation as Ground
	construction.texture_filter = ground.texture_filter
	construction.z_index = ground.z_index
	construction.collision_enabled = false
	construction.navigation_enabled = false
	construction.modulate = Color("ffffff6f")  # same translucency as the preview
	add_child(construction)


func _get_tile_size(src: int, tile: Vector2i) -> Vector2i:
	var atlas_source := preview.tile_set.get_source(src) as TileSetAtlasSource
	if atlas_source:
		return atlas_source.get_tile_size_in_atlas(tile)
	return Vector2i.ONE


# The rectangle (in Ground's local space) that a building actually occupies on
# screen. Godot draws a tile centered on its placement cell, shifted by the
# tile's Texture Origin, so this is not the same as the cells it covers.
func _get_visible_rect(origin: Vector2i, src: int, atlas_coords: Vector2i) -> Rect2:
	var cell_center : Vector2 = ground.map_to_local(origin)
	var atlas_source := ground.tile_set.get_source(src) as TileSetAtlasSource
	if atlas_source == null:
		var cell := Vector2(ground.tile_set.tile_size)
		return Rect2(cell_center - cell / 2.0, cell)
	var region_size := Vector2(atlas_source.get_tile_texture_region(atlas_coords).size)
	var tile_origin := Vector2(atlas_source.get_tile_data(atlas_coords, 0).texture_origin)
	var center := cell_center - tile_origin
	return Rect2(center - region_size / 2.0, region_size)


func _update_placeable() -> void:
	var tile_size := _get_tile_size(source_id, selected_tile)

	placeable = true
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			var tile = preview_tile + Vector2i(x, y)
			if Buildingmanager.used_tiles.has(tile) or reserved_tiles.has(tile):
				placeable = false
				return


func get_snapped_position(global_pos: Vector2) -> Vector2i:
	var local_pos = ground.to_local(global_pos)
	return ground.local_to_map(local_pos)


func _physics_process(_delta):
	if select_mode:
		preview_tile = get_snapped_position(get_global_mouse_position())
	elif delete_mode:
		_update_delete_hover(get_global_mouse_position())


# Returns the origin tile of the building under the given position, or null.
func _find_structure_at(global_pos: Vector2) -> Variant:
	var local_pos : Vector2 = ground.to_local(global_pos)
	var found := false
	var best : Vector2i
	for origin: Vector2i in structures:
		var data : Dictionary = structures[origin]
		if _get_visible_rect(origin, data.src, data.atlas).has_point(local_pos):
			# If buildings overlap, prefer the one drawn in front (lower on screen)
			if not found or origin.y > best.y or (origin.y == best.y and origin.x > best.x):
				best = origin
				found = true
	return best if found else null


func _update_delete_hover(global_pos: Vector2) -> void:
	var origin = _find_structure_at(global_pos)

	if origin == null:
		if has_hovered:
			_clear_delete_hover()
		return

	if has_hovered and origin == hovered_origin:
		return

	_clear_delete_hover()

	hovered_origin = origin
	has_hovered = true
	hovered_structure = Buildingmanager.get_structure_cells(origin)
	removable = not hovered_structure.is_empty()

	var data : Dictionary = structures[origin]
	preview.set_cell(origin, data.src, data.atlas)


func _clear_delete_hover() -> void:
	for cell in hovered_structure:
		preview.erase_cell(cell)
	if has_hovered:
		preview.erase_cell(hovered_origin)
	hovered_structure = []
	has_hovered = false
	removable = false


func _enter_select_mode(new_source_id: int, tile: Vector2i) -> void:
	delete_mode = false
	_clear_delete_hover()
	select_mode = true
	source_id = new_source_id
	selected_tile = tile


func _enter_delete_mode() -> void:
	select_mode = false
	preview.erase_cell(preview_tile)
	delete_mode = true


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and select_mode and placeable:
			start_construction(preview_tile, source_id, selected_tile)
			select_mode = false
		elif event.button_index == MOUSE_BUTTON_LEFT and delete_mode and removable:
			Buildingmanager.remove_structure(ground, hovered_structure)
			structures.erase(hovered_origin)
			_clear_delete_hover()
			delete_mode = false

	# Keyboard shortcuts (still work alongside the menu)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_enter_select_mode(2, Vector2i(12, 6))
		elif event.keycode == KEY_2:
			_enter_select_mode(2, Vector2i(11, 3))
		elif event.keycode == KEY_3:
			_enter_select_mode(2, Vector2i(17, 0))
		elif event.keycode == KEY_R:
			_enter_delete_mode()


func start_construction(tile_pos: Vector2i, src: int, atlas_coords: Vector2i) -> void:
	var tile_size := _get_tile_size(src, atlas_coords)

	# Reserve every cell the building covers
	var cells : Array[Vector2i] = []
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			cells.append(tile_pos + Vector2i(x, y))
	for c in cells:
		reserved_tiles[c] = true

	# Swap the cursor-following preview for a fixed translucent copy
	preview.erase_cell(tile_pos)
	construction.set_cell(tile_pos, src, atlas_coords)

	# Countdown label, centered on the building's visible area
	var center : Vector2 = _get_visible_rect(tile_pos, src, atlas_coords).get_center()
	var label := Label.new()
	label.custom_minimum_size = Vector2(64, 0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	label.z_index = 10
	add_child(label)
	label.position = to_local(ground.to_global(center)) - label.get_combined_minimum_size() / 2.0

	# Count down
	var timer := get_tree().create_timer(build_times.get(atlas_coords, build_time))
	while timer.time_left > 0.0:
		label.text = str(ceili(timer.time_left))
		await get_tree().process_frame

	# Finished: swap translucent for the real thing
	label.queue_free()
	construction.erase_cell(tile_pos)
	for c in cells:
		reserved_tiles.erase(c)
	place_tile(tile_pos, src, atlas_coords)


func place_tile(tile_pos: Vector2i, src: int, atlas_coords: Vector2i) -> void:
	ground.set_cell(tile_pos, src, atlas_coords)
	Buildingmanager.register_structure(ground, atlas_coords, tile_pos)
	structures[tile_pos] = {"src": src, "atlas": atlas_coords}
