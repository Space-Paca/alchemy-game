extends Control

signal closed

onready var recipe_grid : GridContainer = $Background/ScrollContainer/RecipeGrid
onready var scroll : ScrollContainer = $Background/ScrollContainer
onready var filter_menu = $Background/FilterMenu

const RECIPE = preload("res://game/main-menu/CompendiumRecipeDisplay.tscn")

var recipe_displays := {}


class RecipeSorter:
	static func sort_ascending(a, b):
		if a.combination.grid_size == b.combination.grid_size:
			return a.combination.recipe.name < b.combination.recipe.name
		return a.combination.grid_size < b.combination.grid_size


func _ready():
	populate()


func populate():
	var display_array := []
	
	for recipe_name in Profile.known_recipes:
		var display = RECIPE.instance()
		var combination = Combination.new()
		combination.create_from_recipe(RecipeManager.recipes[recipe_name], {})
		display.combination = combination
		recipe_displays[recipe_name] = display
		display_array.append(display)
	
	display_array.sort_custom(RecipeSorter, "sort_ascending")
	
	for display in display_array:
		recipe_grid.add_child(display)
		display.set_combination(display.combination)


func enable_tooltips():
	for display in recipe_grid.get_children():
		if display.visible:
			display.enable_tooltips()
		else:
			display.disable_tooltips()


func disable_tooltips():
	for display in recipe_grid.get_children():
		display.disable_tooltips()


func filter_combinations(filters: Array):
	for recipe_display in recipe_displays.values():
		var filtered = true
		for filter in filters:
			if not filter in recipe_display.combination.recipe.filters:
				filtered = false
				break
		recipe_display.filtered = filtered
	
	update_recipes_shown()


func update_recipes_shown():
	for recipe_display in recipe_displays.values():
		recipe_display.visible = recipe_display.filtered
	if visible:
		enable_tooltips()


func reset_recipe_visibility():
	filter_menu.clear_filters()
	
	for recipe_display in recipe_displays.values():
		recipe_display.filtered = true
		recipe_display.show()


func _on_FilterMenu_filters_updated(filters: Array):
	filter_combinations(filters)


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_CloseButton_pressed():
	emit_signal("closed")
