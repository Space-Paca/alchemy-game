extends TextureButton
class_name FavoriteButton

var combination : Combination
var reagent_array : Array


func set_combination(new_combination: Combination):
	combination = new_combination
	if combination:
		texture_normal = combination.recipe.fav_icon
		reagent_array = combination.recipe.reagents
