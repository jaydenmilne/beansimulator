extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pivot_offset = Vector2(self.size[0] / 2, self.size[1] / 2)


func _on_texture_button_pressed() -> void:
	self.visible = false

