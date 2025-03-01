extends Node

var scale_index = 2
var callback_handle = null
var pixel_ratio = 1.0
const SCALE_FACTORS = [0.25, 0.5, 1, 2, 3, 4, 6]

func on_update_pixel_ratio(arr):
	# install custom scaling logic
	pixel_ratio = JavaScriptBridge.eval("window.devicePixelRatio")
	print("window.devicePixelRatio is `%f`" % pixel_ratio)
	scale_index = clampi(ceili(pixel_ratio) + 1, 0, len(SCALE_FACTORS) - 1)
	var scale = SCALE_FACTORS[scale_index]
	set_custom_scale(scale)

func _enter_tree():
	if OS.get_name() == "Web":
		# install some javascript stuff to make sure we adjust the DPI correctly on high dpi
		# displays
		callback_handle = JavaScriptBridge.create_callback(on_update_pixel_ratio)
		
		JavaScriptBridge.eval("""
// stolen without shame from MDN
let remove = null;

window.on_size_cllback = () => console.log("didn't work :(");
window.cllback_setter = {
	seter: (cllback) => window.on_size_cllback = cllback
};

const updatePixelRatio = () => {
  if (remove != null) {
	remove();
  }
  const mqString = `(resolution: ${window.devicePixelRatio}dppx)`;
  const media = matchMedia(mqString);
  media.addEventListener("change", updatePixelRatio);
  remove = () => {
	media.removeEventListener("change", updatePixelRatio);
  };

  window.on_size_cllback()
};

updatePixelRatio();

	""")
		JavaScriptBridge.get_interface("window").on_size_cllback = callback_handle
		on_update_pixel_ratio([])
		
func set_custom_scale(scale: float):
	get_tree().root.content_scale_factor = scale
	print("scale set to `%f`" % scale)