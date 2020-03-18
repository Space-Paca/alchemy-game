extends TextureButton

var type = "reagent"

func get_drag_data(_pos):
	var reagent = preload("res://test/battle/Reagent.tscn")
	set_drag_preview(reagent.instance())
	return self
