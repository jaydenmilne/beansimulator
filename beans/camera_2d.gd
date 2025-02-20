extends Camera2D

var velocity: Vector2 = Vector2i(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position -= self.velocity * delta
	self.velocity

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			self.velocity = Vector2i(0, 0)
			self.position -= event.relative * (Vector2(1, 1) / self.zoom)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT and not event.pressed:
			var v = Input.get_last_mouse_velocity()
			print(v, v.length())
			
			if v.length() < 400:
				self.velocity = Vector2i(0,0)
			else:
				self.velocity = v * .9
			
