extends MarginContainer

signal home

func _on_homebtn_pressed() -> void:
	home.emit()

func round(i: int) -> String:
	if i < 1000:
		return str(i)
	elif i > 999 and i < 1_000_000:
		return "%.1fK" % [i / 1000.0]
	elif i > 999_999 and i < 1_000_000_000:
		return "%.1fM" % [i / 1_000_000.0]
	elif i > 999_999_999 and i < 1_000_000_000_000:
		return "%.1fB" % [i / 1_000_000_000.0]
	else:
		return "%.1fT" % [i / 1_000_000_000_000.0]
		
func format_money() -> String:
	if Globals.money == 0:
		return "$0"
	if Globals.money < 1:
		return "$%f" % [Globals.money]
	print(Globals.money)
	var int_part = int(Globals.money)
	var frac = Globals.money - int_part
	return "$%s%.2f" % [Globals.thousands_sep(int_part, ","), frac]

var showed_bean_fact_popup = false

func update_inventory():
	$Inventory/MarginContainer/VBoxContainer/BeanCount.text = "Beans: %s" % [self.round(Globals.beans)]
	$Inventory/MarginContainer/VBoxContainer/Money.text = self.format_money()

	if Globals.beans == 0 and not self.showed_bean_fact_popup:
		self.showed_bean_fact_popup = true
		$beanfacttimer.start()

func _ready() -> void:
	Globals.update_inventory.connect(self.update_inventory)
	self.update_inventory()
 
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


func _on_timer_timeout() -> void:
	$cameracoords.text = str(self.get_viewport().get_camera_2d().position)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_J) and Input.is_key_pressed(KEY_M):
			$CommandBar.visible = true
			$CommandBar.text = ""
			$CommandBar.grab_focus()


func run_debug_command(cmd: String):
	if cmd.begins_with("coords"):
		print("toggling coords...")
		Globals.debug_state = not Globals.debug_state
		Globals.toggle_debug.emit(Globals.debug_state)
		$cameracoords.visible = Globals.debug_state
	elif cmd.begins_with("fgrow"):
		print("forcing grow...")
		Globals.force_grow.emit()
	elif cmd.begins_with("give"):
		var split = cmd.split(" ")
		if split[1] == "beans":
			Globals.update_beans(int(split[2]))
		elif split[1] == "money":
			Globals.update_money(float(split[2]))

func _on_command_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ENTER:
			self.run_debug_command($CommandBar.text)
			$CommandBar.text = ""

func _on_bluebtn_pressed() -> void:
	$CenterContainer/SellBeans.visible = not $CenterContainer/SellBeans.visible


func _on_beanfacttimer_timeout() -> void:
	$CenterContainer/BeanFact.visible = true
