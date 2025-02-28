extends Node

enum MOUSE_MODE {
	DRAG,
	PLANT,
	CUT,
}

var mouse_mode: MOUSE_MODE = MOUSE_MODE.DRAG

var game_seed

var debug_state = false
signal toggle_debug(state: bool)
signal force_grow

signal update_inventory

var beans = 32
var money = 0.0
const GAME_FILENAME = "user://inventory.beaninfo"

func _enter_tree() -> void:
	if FileAccess.file_exists(GAME_FILENAME):
		var f = FileAccess.open_compressed(GAME_FILENAME, FileAccess.READ, FileAccess.CompressionMode.COMPRESSION_ZSTD)
		var game_data = await JSON.parse_string(f.get_as_text())
		self.beans = game_data['beans']
		self.money = game_data['money']

func save_game() -> void:
	if FileAccess.file_exists(GAME_FILENAME):
		DirAccess.remove_absolute(GAME_FILENAME)

	var f = FileAccess.open_compressed(GAME_FILENAME, FileAccess.WRITE_READ, FileAccess.CompressionMode.COMPRESSION_ZSTD)
	
	if f == null:
		print("failed to write file! ", FileAccess.get_open_error())
		return
	
	f.store_string(JSON.stringify({"beans": self.beans, "money": self.money}))

func update_beans(count: int) -> void:
	self.beans += count
	self.update_inventory.emit()
	self.save_game()

func update_money(count: float) -> void:
	self.money += count
	self.update_inventory.emit()
	self.save_game()