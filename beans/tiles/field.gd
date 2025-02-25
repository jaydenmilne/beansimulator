extends Node2D

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

func _unhandled_input(event: InputEvent) -> void:
	if Globals.mouse_mode != Globals.MOUSE_MODE.DRAG and event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MASK_LEFT and event.pressed:
				var p = $ground.local_to_map($ground.to_local(self.get_global_mouse_position()))
				var cell = $ground.get_cell_atlas_coords(p)
				if cell in FIELD_CELLS:
					$corn.set_cell(p, 0, Vector2i(12, 0))

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
