extends TextureRect

func can_drop_data(_pos, data):
	return data.type == "reagent"


func drop_data(_pos, data):
	$Reagent.texture = data.texture
