extends MarginContainer


const GCAL_LINK_TEMPLATE = "https://calendar.google.com/calendar/render?action=TEMPLATE&text=Harvest+Beans&details=https://beans.jayd.ml&dates={start}/{end}"

const ICAL_TEMPLATE = """
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//beans.jayd.ml//beans
CALSCALE:GREGORIAN
BEGIN:VEVENT
DTSTAMP:{created}
UID:{uuid}
DTSTART:{start}
DTEND:{end}
SUMMARY:Harvest Beans
URL:https://beans.jayd.ml
DESCRIPTION:https://beans.jayd.ml
END:VEVENT
END:VCALENDAR
"""

func get_gcal_time_str(utc: float) -> String:
	var d = Time.get_datetime_dict_from_unix_time(int(utc))
	return "%d%02d%02dT%02d%02d%02dZ" % [d["year"], d["month"], d["day"], d["hour"], d["minute"], d["second"]]

func get_bean_ready_time() -> float:
	return Time.get_unix_time_from_system() + Globals.MIN_BEAN_MATURATION_TIME + Globals.BEAN_MATURATION_TIME_VARIANCE

func _on_gcal_pressed() -> void:
	var time_unix = get_bean_ready_time()
	OS.shell_open(GCAL_LINK_TEMPLATE.format({"start": get_gcal_time_str(time_unix), "end": get_gcal_time_str(time_unix + 15 * 60)}))

func _on_icsbutton_pressed() -> void:
	var time_unix = get_bean_ready_time()

	var rng = RandomNumberGenerator.new()
	rng.seed = int(Time.get_unix_time_from_system())

	var ical_file = ICAL_TEMPLATE.format({
		"created": self.get_gcal_time_str(Time.get_unix_time_from_system()),
		"uuid": str(rng.randi()),
		"start": self.get_gcal_time_str(time_unix),
		"end": self.get_gcal_time_str(time_unix + 15 * 60)
	})

	JavaScriptBridge.download_buffer(ical_file.to_utf8_buffer(), "invite.ics", "text/calendar")