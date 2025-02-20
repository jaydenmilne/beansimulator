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
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# field itself
	for x in range(field_width):
		for y in range(field_height):
			$ground.set_cell(Vector2i(x, y), 0, Vector2i(3, 1))
			
	# fence top
	for x in range(0, field_width):
		$fence.set_cell(Vector2i(x, -1), 0, FENCE_TOP)
		$fence.set_cell(Vector2i(x, field_height), 0, FENCE_BOTTOM)
		
	for y in range(0, field_height):
		$fence.set_cell(Vector2i(-1, y), 0, FENCE_LEFT)
		$fence.set_cell(Vector2i(field_width, y), 0, FENCE_RIGHT)
	
	# dirt paths
	for x in range(-1, field_width+1):
		$ground.set_cell(Vector2i(x, -1), 0, Vector2i(7 + randi_range(0, 3), 1))
		$ground.set_cell(Vector2i(x, field_height), 0, Vector2i(7 + randi_range(0, 3), 1))

	for y in range(0, field_height+1):
		$ground.set_cell(Vector2i(-1, y), 0, Vector2i(7 + randi_range(0, 3), 1))
		$ground.set_cell(Vector2i(field_width, y), 0, Vector2i(7 + randi_range(0, 3), 1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
