extends Node2D

class_name Room_Fragment

@export var has_cagedGecko: bool = false
@onready var cagedgecko_scene = preload("res://Scenes/Enemies/enemy.tscn")
#
@onready var tilemap: TileMap
@onready var enemy_scene: PackedScene = preload("res://Scenes/Enemies/enemy.tscn")
@export var spawn_count: int = 5
@export var min_distance: float = 32  #minimum pixels between enemies
@export var wall_terrain_name: String = "GroundWalls"

func _ready():
	if has_cagedGecko:
		spawn_cagedgecko()
		
	var tilemap_layer = get_node_or_null("Tilemap/BaseMapLayer") as TileMapLayer
	if not tilemap_layer:
		push_warning("TileMapLayer not found!")
		return
	spawn_enemies(tilemap_layer)

func spawn_cagedgecko():
	var spawn_point = find_child("CagedGecko_Spawner", true, false)
	if not spawn_point:
		push_warning("No 'CagedGecko_Spawner' found in room!")
		return
		
	var gecko = cagedgecko_scene.instantiate()
	spawn_point.add_child(gecko)
	gecko.position = Vector2.ZERO

###################enemy spawn
func get_walkable_tiles(tilemap_layer: TileMapLayer) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var tileset = tilemap_layer.tile_set
	
	#print_debug(tileset.get_terrain_name(0,0))
	

	# get all tiles placed in the layer
	var placed_tiles = tilemap_layer.get_used_cells()
	for tile_data in placed_tiles:
		var cell = Vector2i(tile_data.x, tile_data.y)  # Vector2i cell coordinates
		var test: TileData = tilemap_layer.get_cell_tile_data(cell)
		if test.terrain_set == -1:
			tiles.append(cell)
	return tiles


func spawn_enemies(tilemap_layer: TileMapLayer):
	var spawnable_tiles = get_walkable_tiles(tilemap_layer)
	if spawnable_tiles.is_empty():
		push_warning("No walkable tiles found for enemy spawning!")
		return

	var spawned_positions: Array[Vector2] = []
	var attempts = 0

	while spawned_positions.size() < spawn_count and attempts < spawn_count:
		attempts += 1

		var cell = spawnable_tiles[randi() % spawnable_tiles.size()]
		var world_pos = tilemap_layer.map_to_local(cell)

		# check minimum distance from already spawned enemies
		var too_close = false
		for pos in spawned_positions:
			if pos.distance_to(world_pos) < min_distance:
				too_close = true
				break

		if too_close:
			continue

		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position = world_pos
		spawned_positions.append(world_pos)
