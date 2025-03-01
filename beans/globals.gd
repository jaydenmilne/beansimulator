extends Node

enum MOUSE_MODE {
	DRAG,
	PLANT,
	CUT,
}

const SECS_PER_DAY = 60 * 60 * 24

const MIN_BEAN_MATURATION_TIME = 50 * SECS_PER_DAY
const BEAN_MATURATION_TIME_VARIANCE = 5 * SECS_PER_DAY

var mouse_mode: MOUSE_MODE = MOUSE_MODE.DRAG

var game_seed: float

var debug_state = false
signal toggle_debug(state: bool)
signal force_grow

signal update_inventory

var beans = 32
var money = 0.0
const GAME_FILENAME = "user://game.beaninfo"

func _enter_tree() -> void:
	if FileAccess.file_exists(GAME_FILENAME):
		var f = FileAccess.open_compressed(GAME_FILENAME, FileAccess.READ, FileAccess.CompressionMode.COMPRESSION_ZSTD)
		var game_data = await JSON.parse_string(f.get_as_text())
		self.beans = game_data['beans']
		self.money = game_data['money']
		self.game_seed = game_data['game_seed']
		print("game seed is ", self.game_seed)
	else:
		# new random seed
		self.game_seed = Time.get_unix_time_from_system()

func save_game() -> void:
	if FileAccess.file_exists(GAME_FILENAME):
		DirAccess.remove_absolute(GAME_FILENAME)

	var f = FileAccess.open_compressed(GAME_FILENAME, FileAccess.WRITE_READ, FileAccess.CompressionMode.COMPRESSION_ZSTD)
	
	if f == null:
		print("failed to write file! ", FileAccess.get_open_error())
		return
	
	f.store_string(JSON.stringify({"beans": self.beans, "money": self.money, "game_seed": self.game_seed}))

func update_beans(count: int) -> void:
	self.beans += count
	self.update_inventory.emit()
	self.save_game()

func update_money(count: float) -> void:
	self.money += count
	self.update_inventory.emit()
	self.save_game()
	
func thousands_sep(number: int, separator: String = "") -> String:
	var in_str = str(number)
	var out_chars = PackedStringArray()
	var length = in_str.length()
	for i in length:
		var idx = i + 1 # add digits from last to first
		out_chars.append(in_str[length - idx]) # every 3 digits add a separator, unless we're at the end
		if i < length - 1 and idx % 3 == 0:
			out_chars.append(separator)
	# invert it so it's back in the right order       
	out_chars.reverse()
	# convert to single string and return 
	return "".join(out_chars)
