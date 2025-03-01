extends MarginContainer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $VBoxContainer/BeanCount == null:
		$VBoxContainer/BeanCount.text = str(0)
		

var beans_to_sell = 0.0

func _on_h_slider_value_changed(value: float) -> void:
	self.beans_to_sell = floor(Globals.beans * value)
	$VBoxContainer/BeanCount.text = Globals.thousands_sep(self.beans_to_sell, ",")

# https://www.marketnews.usda.gov/mnp/fv-report-top-filters?&commAbr=BNS&rowDisplayMax=25&repType=termPriceDaily&navType=byComm&navClass=VEGETABLES&locName=&commName=BEANS&className=VEGETABLES&type=termPrice&startIndex=26
const PRICE_PER_BUSHEL = 48.0
# https://www.foodbankcny.org/assets/Documents/Vegetable-conversion-chart.pdf
const POUNDS_PER_BUSHEL = 28
const BEANS_PER_POUND = 35
const PRICE_PER_BEAN = PRICE_PER_BUSHEL / (POUNDS_PER_BUSHEL * BEANS_PER_POUND)

func _on_texture_button_pressed() -> void:
	if self.beans_to_sell == 0:
		return
	if Globals.beans - self.beans_to_sell <= 0:
		self.beans_to_sell = Globals.beans - 1
	print("selling ", self.beans_to_sell, " beans")
	Globals.update_beans(-1 * self.beans_to_sell)
	Globals.update_money(self.beans_to_sell * PRICE_PER_BEAN)
	$VBoxContainer/HSlider.value = 0
	self.beans_to_sell = 0
	$sellsnd.play()
