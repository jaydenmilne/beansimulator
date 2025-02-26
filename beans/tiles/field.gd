extends Node2D

const FIELD_SIZE = 1024
const FENCE_TOP = Vector2i(16, 1)
const FENCE_BOTTOM = Vector2i(13, 1)
const FENCE_RIGHT = Vector2i(11, 1)
const FENCE_LEFT = Vector2i(14, 1)

@export
var field_width: int = 32
@export
var field_height: int = 16

var field_id: Vector2i = Vector2i(0, 0)

var direction: int = 0

var FIELD_CELLS = [Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1)]
var BEAN_CELLS = [Vector2i(12, 0), Vector2i(13, 0), Vector2i(14, 0), Vector2i(15, 0)]
const BLANK_CELL = Vector2i(-1, -1)

func init_field(id: Vector2i):
	var rng = RandomNumberGenerator.new()
	rng.set_seed(hash(id))
	self.field_id = id
	$debugstr.text = str(field_id)
	# decide row direction
	direction = rng.randi_range(0, 3)
	
	# field itself
	for x in range(1, field_width - 1):
		for y in range(1, field_height - 1):
			$ground.set_cell(Vector2i(x, y), 0, Vector2i(3 + direction, 1))
			
	# fence top
	for x in range(1, field_width - 1):
		$fence.set_cell(Vector2i(x, 0), 0, FENCE_TOP)
		$fence.set_cell(Vector2i(x, field_height - 1), 0, FENCE_BOTTOM)
		
	for y in range(1, field_height - 1):
		$fence.set_cell(Vector2i(0, y), 0, FENCE_LEFT)
		$fence.set_cell(Vector2i(field_width - 1, y), 0, FENCE_RIGHT)
	
	# dirt paths
	for x in range(field_width):
		$ground.set_cell(Vector2i(x, 0), 0, Vector2i(7 + rng.randi_range(0, 3), 1))
		$ground.set_cell(Vector2i(x, field_height - 1), 0, Vector2i(7 + rng.randi_range(0, 3), 1))

	for y in range(field_height):
		$ground.set_cell(Vector2i(0, y), 0, Vector2i(7 + rng.randi_range(0, 3), 1))
		$ground.set_cell(Vector2i(field_width - 1, y), 0, Vector2i(7 + rng.randi_range(0, 3), 1))

var last_position

func get_event_tilemap_coords(event: InputEventMouse) -> Vector2i:
	var c = self.get_canvas_transform().affine_inverse() * event.global_position
	return $ground.local_to_map($ground.to_local(c))

func position_in_this_field(p: Vector2i) -> bool:
	var ground_cell = $ground.get_cell_atlas_coords(p)
	return ground_cell in FIELD_CELLS

func field_click(p: Vector2i):
	if not self.position_in_this_field(p):
		return

	var bean_cell = $beans.get_cell_atlas_coords(p)

	if Globals.mouse_mode == Globals.MOUSE_MODE.PLANT and bean_cell == BLANK_CELL:
		$beans.set_cell(p, 0, BEAN_CELLS[self.direction])
	
	if Globals.mouse_mode == Globals.MOUSE_MODE.CUT and bean_cell != BLANK_CELL:
		$beans.set_cell(p, 0, BLANK_CELL)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and last_position != null:
		var c = self.get_event_tilemap_coords(event)
		if not self.position_in_this_field(c):
			return
		if c != last_position:
			# bresenham up in this house
			var x0 = c[0]
			var y0 = c[1]
			var x1 = last_position[0]
			var y1 = last_position[1]

			var dx = abs(x0 - x1)
			var dy = -1 * abs(y0 - y1)

			var sx = -1
			if x0 < x1:
				sx = 1
			
			var sy = -1
			if y0 < y1:
				sy = 1

			var err = dx + dy
			while true:
				field_click(Vector2i(x0, y0))
				if x0 == x1 && y0 == y1:
					break
				
				var e2 = 2 * err
				if (e2 >= dy):
					err += dy
					x0 += sx
				
				if e2 <= dx:
					err += dx
					y0 += sy
				
			last_position = c

	if Globals.mouse_mode != Globals.MOUSE_MODE.DRAG and event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MASK_LEFT and event.pressed:
				# https://old.reddit.com/r/godot/comments/s6pvat/turning_screen_coordinates_to_world_coordinates/hzi6t25/
				last_position = get_event_tilemap_coords(event)
				field_click(last_position)


	if event is InputEventMouseButton and not event.pressed:
		last_position = null
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
