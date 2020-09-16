extends Control

signal pressed

var artifact

func setup(_artifact):
	artifact = _artifact
	$Image.texture = artifact.image

func disable():
	$Button.disabled = true

func _on_Button_pressed():
	emit_signal("pressed", artifact)
