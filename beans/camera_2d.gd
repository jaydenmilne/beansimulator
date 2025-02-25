extends Camera2D

var velocity: Vector2 = Vector2i(0, 0)

func _process(delta: float) -> void:
	self.position -= self.velocity * delta

func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			if (
					event.button_mask & MOUSE_BUTTON_MASK_LEFT
					and Globals.mouse_mode == Globals.MOUSE_MODE.DRAG
				) or event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
				self.velocity = Vector2i(0, 0)
				self.position -= event.relative * (Vector2(1, 1) / self.zoom)
		if event is InputEventMouseButton:
			if ((
					event.button_index & MOUSE_BUTTON_MASK_LEFT
					and Globals.mouse_mode == Globals.MOUSE_MODE.DRAG
				) or event.button_index & MOUSE_BUTTON_MASK_MIDDLE) and not event.pressed:
				var v = Input.get_last_mouse_velocity()
			
				if v.length() < 400:
					self.velocity = Vector2i(0, 0)
				else:
					self.velocity = v * .9
