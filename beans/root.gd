extends Node2D

const FIELD_TILE_WIDTH = 32
const FIELD_TILE_HEIGHT = 16

const TILE_WIDTH = 256
const TILE_HEIGHT = 128

const FIELD_WIDTH = TILE_HEIGHT * FIELD_TILE_WIDTH
const FIELD_HEIGHT = TILE_HEIGHT * FIELD_TILE_HEIGHT

var field_map = {}

func set_field_at(logical_field_pos: Vector2i, field):
	field.init_field(logical_field_pos)
	field_map[logical_field_pos] = field
	var p = logical_field_pos * Vector2i(FIELD_WIDTH, FIELD_HEIGHT)
	field.set_position(p)

var fields = load("res://tiles/field.tscn")

func init_fields():
	# figure out the size of the screen
	var size = self.get_viewport_rect().size
	
	# fields horizontal
	var fields_horizontal = ceil(size.x / FIELD_WIDTH) * 5
	var fields_vertical = ceil(size.y / FIELD_HEIGHT) * 5
	print("horizontal", fields_horizontal, "vertical", fields_vertical)
	for x in range(fields_horizontal / 2, fields_horizontal / -2, -1):
		for y in range(fields_vertical / -2, fields_vertical / 2):
			var f = fields.instantiate()
			self.set_field_at(Vector2i(x, y), f)
			self.add_child(f)

func what_field_is_point_in(p: Vector2i):
	for field_id in field_map.keys():
		var field = field_map[field_id]

		var n = field.get_node('ground')
		var l = n.local_to_map(n.to_local(p))
			
		if l[0] > 0 and l[0] < FIELD_TILE_WIDTH + 1 and l[1] > 0 and l[1] < FIELD_TILE_HEIGHT + 1:
			return field_id
			

func update_fields():
	# first, figure out what field the camera is in
	var p = $Camera2D.position
	var camera_field = what_field_is_point_in(p)
	
	if camera_field == null:
		return

	var cullable_fields = []
	
	var size = self.get_viewport_rect().size
	var min_fields_horizontal = ceil(size.x / FIELD_WIDTH) * 2
	var min_fields_vertical = ceil(size.y / FIELD_HEIGHT) * 2
	
	for field_id in field_map:
		if abs(camera_field[0] - field_id[0]) > min_fields_horizontal or abs(camera_field[1] - field_id[1]) > min_fields_vertical:
			#print("cull ", field_id)
			cullable_fields.push_back(field_id)
			
	for x in range(camera_field[0] - min_fields_horizontal, camera_field[0] + min_fields_horizontal):
		for y in range(camera_field[1] - min_fields_horizontal, camera_field[1] + min_fields_horizontal):
			if not field_map.has(Vector2i(x, y)):
				# steal one from cullable
				# TODO: check if we need to spawn a new one
				var victim_id = cullable_fields.pop_front()
				if len(cullable_fields) == 0:
					print("spawning new field???")
					var f = fields.instantiate()
					self.set_field_at(Vector2i(x, y), f)
					self.add_child(f)
				else:
					print("need (", x, ", ", y, "), stealing ", victim_id)
					
					var victim = field_map[victim_id]
					field_map.erase(victim_id)
					self.set_field_at(Vector2i(x, y), victim)
	

func reset_timer():
	var rnd = RandomNumberGenerator.new()
	rnd.seed = int(Time.get_unix_time_from_system())
	$musictimer.wait_time = rnd.randi_range(10 * 60, 60 * 60)
	$musictimer.stop()
	$musictimer.start()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.init_fields()
	self.reset_timer()

func _on_timer_timeout() -> void:
	self.update_fields()

func _on_ui_home() -> void:
	# reset everything
	for field_id in field_map:
		field_map[field_id].queue_free()
	field_map = {}
	self.init_fields() # lol make some more why not
	$Camera2D.position = Vector2i(0, 0)
	$Camera2D.velocity = Vector2i(0, 0)

func _on_musictimer_timeout() -> void:
	$music.play()

func _on_music_finished() -> void:
	self.reset_timer()
