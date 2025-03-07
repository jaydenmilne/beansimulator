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
var BABY_BEAN_CELLS = [Vector2i(12, 0), Vector2i(13, 0), Vector2i(14, 0), Vector2i(15, 0)]
var BIG_BEAN_CELLS = [Vector2i(8, 0), Vector2i(9, 0), Vector2i(10, 0), Vector2i(11, 0)]

const BLANK_CELL = Vector2i(-1, -1)

const PLANT_SOUNDS = [
	preload("res://sound/footstep_grass_000.ogg"),
	preload("res://sound/footstep_grass_001.ogg"),
	preload("res://sound/footstep_grass_002.ogg"),
	preload("res://sound/footstep_grass_003.ogg"),
	preload("res://sound/footstep_grass_004.ogg"),
]

const CUT_SOUNDS = [
	preload("res://sound/drawKnife1.ogg"),
	preload("res://sound/drawKnife2.ogg"),
	preload("res://sound/drawKnife3.ogg"),
]

const DETRITUS = [
	Vector2i(6, 2),
	Vector2i(7, 2),
	Vector2i(8, 2),
	Vector2i(9, 2),
	Vector2i(10, 2),
	Vector2i(11, 2),
	Vector2i(12, 2),
	Vector2i(13, 2),
	Vector2i(14, 2),
	Vector2i(15, 2),
	Vector2i(16, 2),
	Vector2i(17, 2),
	Vector2i(6, 6),
	Vector2i(7, 6),
	Vector2i(8, 6),
	Vector2i(9, 6),
	Vector2i(10, 6),
	Vector2i(11, 6),
	Vector2i(12, 6),
	Vector2i(13, 6),
]

"""
Field File Format

{
	"version": "1",
	"beans": {
		"3": {
			"3": {
				"t": 12314151511,
			}
		}
	}

}

"""

var field_data = {}
var maturationrng = RandomNumberGenerator.new()

func get_field_filename(id: Vector2i) -> String:
	return "user://fields/%s_%s.beans" % [str(id[0]).replace('-', 'm'), str(id[1]).replace('-', 'm')]
func load_beans(id: Vector2i):
	var filename = self.get_field_filename(id)
	var dir = DirAccess.open("user://")
	dir.make_dir('fields')

	if not FileAccess.file_exists(filename):
		field_data["version"] = "1"
		field_data["beans"] = {}
		return

	var f = FileAccess.open_compressed(filename, FileAccess.READ, FileAccess.CompressionMode.COMPRESSION_ZSTD)
	field_data = await JSON.parse_string(f.get_as_text())

	self.refresh_field()

const DETRITUS_CHANCE = 10

func init_field(id: Vector2i):
	$fwddetritus.clear()
	$backdetritus.clear()
	$beans.clear()
	var rng = RandomNumberGenerator.new()
	rng.set_seed(hash(id) + hash(Globals.game_seed))
	maturationrng.set_seed(hash(id) + Time.get_unix_time_from_system())
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
	
	var rand_detritus = func() -> Vector2i:
		return DETRITUS[rng.randi_range(0, len(DETRITUS)-1)]

	# dirt paths & detritus
	for x in range(field_width):
		if rng.randi_range(0, DETRITUS_CHANCE) == 1:
			$backdetritus.set_cell(Vector2i(x, 0), 0, rand_detritus.call())
		if rng.randi_range(0, DETRITUS_CHANCE) == 1:
			$fwddetritus.set_cell(Vector2i(x, field_height - 1), 0, rand_detritus.call())

		$ground.set_cell(Vector2i(x, 0), 0, Vector2i(7 + rng.randi_range(0, 3), 1))
		$ground.set_cell(Vector2i(x, field_height - 1), 0, Vector2i(7 + rng.randi_range(0, 3), 1))

	for y in range(field_height):
		if rng.randi_range(0, DETRITUS_CHANCE) == 1:
			$backdetritus.set_cell(Vector2i(0, y), 0, rand_detritus.call())
		if rng.randi_range(0, DETRITUS_CHANCE) == 1:
			$fwddetritus.set_cell(Vector2i(field_width - 1, y), 0, rand_detritus.call())

		$ground.set_cell(Vector2i(0, y), 0, Vector2i(7 + rng.randi_range(0, 3), 1))
		$ground.set_cell(Vector2i(field_width - 1, y), 0, Vector2i(7 + rng.randi_range(0, 3), 1))

	# clear the bits and bobs



	load_beans(id)
var last_position

func get_event_tilemap_coords(event: InputEventMouse) -> Vector2i:
	var c = self.get_canvas_transform().affine_inverse() * event.global_position
	return $ground.local_to_map($ground.to_local(c))

func position_in_this_field(p: Vector2i) -> bool:
	var ground_cell = $ground.get_cell_atlas_coords(p)
	return ground_cell in FIELD_CELLS



func get_bean_ready_date():
	# https://www.georgina.ca/sites/default/files/page_assets/planting_growing_harvesting_green_beans.pdf
	var t = Time.get_unix_time_from_system()
	t += Globals.MIN_BEAN_MATURATION_TIME
	t += self.maturationrng.randi_range(0, Globals.BEAN_MATURATION_TIME_VARIANCE)
	return t

func plant_cell(c: Vector2i):
	$beans.set_cell(c, 0, BABY_BEAN_CELLS[self.direction])
	var beans = self.field_data['beans']
	var x = str(c[0])
	var y = str(c[1])

	if x not in beans:
		beans[x] = {}
	
	beans[x][y] = {"t": self.get_bean_ready_date()}
	$writefield.stop()
	$writefield.start()
	$sound.stream = PLANT_SOUNDS[maturationrng.randi_range(0, len(PLANT_SOUNDS)-1)]
	$sound.play()

func harvest_cell(c: Vector2i):
	var beans = self.field_data['beans']
	var x = str(c[0])
	var y = str(c[1])

	beans[x].erase(y)
	$beans.set_cell(c, 0, BLANK_CELL)
	Globals.update_beans(self.maturationrng.randi_range(100, 120))
	$writefield.stop()
	$writefield.start()
	$sound.stream = CUT_SOUNDS[maturationrng.randi_range(0, len(CUT_SOUNDS)-1)]
	$sound.play()

func _on_writefield_timeout() -> void:
	print("saving field ", str(self.field_id))
	var filename = self.get_field_filename(self.field_id)
	if OS.get_name() == "Web":
		# we can at least try
		JavaScriptBridge.eval("navigator.storage.persist()")

	if FileAccess.file_exists(filename):
		DirAccess.remove_absolute(filename)

	var f = FileAccess.open_compressed(filename, FileAccess.WRITE_READ, FileAccess.CompressionMode.COMPRESSION_ZSTD)
	
	if f == null:
		print("failed to write file! ", FileAccess.get_open_error())
		return
	
	f.store_string(JSON.stringify(self.field_data))


func field_click(p: Vector2i):
	if not self.position_in_this_field(p):
		return

	var bean_cell = $beans.get_cell_atlas_coords(p)

	if Globals.mouse_mode == Globals.MOUSE_MODE.PLANT and bean_cell == BLANK_CELL:
		if Globals.beans < 1:
			return
		self.plant_cell(p)
		Globals.update_beans(-1)
	if Globals.mouse_mode == Globals.MOUSE_MODE.CUT and bean_cell != BLANK_CELL and bean_cell in BIG_BEAN_CELLS:
		self.harvest_cell(p)


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

func refresh_field():
	for x in field_data["beans"].keys():
		for y in field_data["beans"][x].keys():
			if field_data["beans"][x][y]["t"] < Time.get_unix_time_from_system():
				$beans.set_cell(Vector2i(int(x), int(y)), 0, BIG_BEAN_CELLS[self.direction])
			else:
				$beans.set_cell(Vector2i(int(x), int(y)), 0, BABY_BEAN_CELLS[self.direction])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.toggle_debug.connect(
		func(state: bool):
			$debugstr.visible = state
	)

	Globals.force_grow.connect(
		func():
			# force everything to be grown
			for x in field_data["beans"].keys():
					for y in field_data["beans"][x].keys():
						field_data["beans"][x][y]["t"] = 0
			self.refresh_field()
	)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_refresh_timeout() -> void:
	self.refresh_field()
