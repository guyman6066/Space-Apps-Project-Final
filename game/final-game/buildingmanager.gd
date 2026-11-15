extends Node2D
 

var used_tiles : Dictionary = {}
 
 
func register_structure(layer: TileMapLayer, selected_tile: Vector2i, origin: Vector2i) -> void:
	var source_id = layer.get_cell_source_id(origin)
	var atlas_source : TileSetAtlasSource = layer.tile_set.get_source(source_id)
	var tile_size := Vector2i.ONE
	if atlas_source:
		tile_size = atlas_source.get_tile_size_in_atlas(selected_tile)
 
	var cells : Array = []
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			cells.append(origin + Vector2i(x, y))
 
	for cell in cells:
		used_tiles[cell] = cells
 
 
func get_structure_cells(tile_pos: Vector2i) -> Array:
	return used_tiles.get(tile_pos, [])
 
 
func remove_structure(layer: TileMapLayer, cells: Array) -> void:
	for cell in cells:
		layer.erase_cell(cell)
		used_tiles.erase(cell)
