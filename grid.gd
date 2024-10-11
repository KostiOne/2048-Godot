extends Node2D

signal  input_block(bool)

@export var rows = 4
@export var cols = 4
@export var cell_size = 32

var grid_cell_prefab = preload("res://grid_cell.tscn")
var tile_prefab = preload("res://tile.tscn")

var grid = Dictionary()
var origin: Vector2

func spawn_prefab(prefab,pos):
	var instance = prefab.instantiate()
	instance.position = get_grid_position(pos)
	add_child(instance)
	return instance


func get_grid_position(grid_pos: Vector2):
	return origin + cell_size * grid_pos + 0.5 * Vector2(cell_size,cell_size)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Engine.time_scale = 0.2
	
	var grid_size = cell_size * Vector2(cols,rows)
	origin = 0.5 * get_viewport_rect().size - 0.5 * grid_size
	
	for i in range(cols):
		for j in range(rows):
			spawn_prefab(grid_cell_prefab,Vector2(i,j))
	
	var input = get_parent().get_node("Input")
	
	input.connect_block_signal()
	
	emit_signal("input_block", false)
	add_tile(false,2)
	add_tile(false,2)
	
	get_parent().get_node("Input").connect("swipe", _on_swiped)

func _on_swiped(dir):
	#print("swiped", dir)
	clear_merged_flags()
	slide_tiles(dir)
	add_tile(true,2)
	emit_signal("input_block", true)
	await  get_tree().create_timer(1).timeout
	emit_signal("input_block", false)

func slide_tiles(dir):
	if dir == Vector2.LEFT:
		for j in range(rows):
			for i in range(cols):
				if grid.has(Vector2(i,j)):
					slide_tile(Vector2(i,j), dir)
	elif dir == Vector2.RIGHT:
		for j in range(rows):
			for i in range(cols - 1, -1, -1):
				if grid.has(Vector2(i,j)):
					slide_tile(Vector2(i,j), dir)
	elif dir == Vector2.UP:
		for i in range(cols):
			for j in range(rows):
				if grid.has(Vector2(i,j)):
					slide_tile(Vector2(i,j), dir)
	elif dir == Vector2.DOWN:
		for i in range(cols):
			for j in range(rows -1, -1, -1):
				if grid.has(Vector2(i,j)):
					slide_tile(Vector2(i,j), dir)

func slide_tile(grid_pos, dir):
	var last_empty = find_last_empty_cell(grid_pos, dir)
	
	var tile = get_tile(grid_pos)
	var should_merge:bool = false
	#tile.position = get_grid_position(last_empty)
	
	if not out_of_bounds(last_empty + dir) and grid.has(last_empty + dir) and grid[last_empty + dir].value == tile.value and tile.has_merged == false and grid [last_empty + dir].has_merged == false:
		should_merge = true
	
	if should_merge:
		var tile_merged = get_tile(last_empty + dir)
		tile_merged.has_merged = true
		tile.has_merged = true
		tile.animate_tile(get_grid_position(last_empty + dir), true)
		grid.erase(grid_pos)
		tile_merged.animate_merge()
	else:
		tile.animate_tile(get_grid_position(last_empty), false)
		move_tile(grid_pos, last_empty)
	

func add_tile(has_delay, value):
	var grid_pos = random_grid_position()
	
		
	var tile = spawn_prefab(tile_prefab,grid_pos)
	
	tile.animate_spawn(has_delay)
	tile.update_value(value)
	grid[grid_pos] = tile

func get_tile(grid_pos):
	if grid.has(grid_pos):
		return grid[grid_pos]
	return false

func move_tile(from, to):
	var temp = grid[from]
	grid.erase(from)
	grid[to] = temp

func out_of_bounds(grid_pos):
	if grid_pos.x < 0 or grid_pos.x >= cols:
		return true
	if grid_pos.y < 0 or grid_pos.y >= rows:
		return true
	return false

func find_last_empty_cell(grid_pos,dir):
	var pos = grid_pos + dir
	var tile = get_tile(pos)
	while  not tile and not out_of_bounds(pos):
		pos += dir
		tile = get_tile(pos)
		
	return pos - dir

func random_grid_position():
	var empty_grid_pos_array = []
	for i in range(cols):
		for j in range(rows):
			if not grid.has(Vector2(i,j)):
				empty_grid_pos_array.push_back(Vector2(i,j))
	
	var size = empty_grid_pos_array.size()
	if size > 0:
		var randomIndex = randi_range(0, size - 1)
		return empty_grid_pos_array[randomIndex]
	
	return false

func clear_merged_flags():
	for i in range(cols):
		for j in range(rows):
			if grid.has(Vector2(i,j)):
				grid[Vector2(i,j)].has_merged = false
