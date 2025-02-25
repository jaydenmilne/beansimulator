extends MarginContainer

signal home

func _on_homebtn_pressed() -> void:
	home.emit()

 
func _on_sellbtn_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_dragbtn_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.mouse_mode = Globals.MOUSE_MODE.DRAG


func _on_plantbtn_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.mouse_mode = Globals.MOUSE_MODE.PLANT

func _on_cutbtn_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.mouse_mode = Globals.MOUSE_MODE.CUT
