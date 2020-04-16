extends CanvasLayer

signal continue_pressed

func _ready():
	pass


func _on_Button_pressed():
	emit_signal("continue_pressed")
