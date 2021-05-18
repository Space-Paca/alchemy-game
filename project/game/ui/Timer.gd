extends Control

func _ready():
	update_timer(0.0)

func update_timer(value):
	var hours = floor(value/3600)
	value = fmod(value, 3600.0)
	var minutes = floor(value/60)
	value = fmod(value, 60.0)
	var seconds = "%02d" % value
	var mili = value - int(value)
	mili = "%.2f" % mili
	if hours > 0:
		$Container/Time.text = str(hours) + ":" + str("%02d"%minutes)+":"+seconds+"."
	else:
		$Container/Time.text = str("%02d"%minutes)+":"+seconds+"."
	$Container/MiliTime.text = mili.substr(2)
