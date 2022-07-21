extends Control

signal closed

onready var recipe_grid : GridContainer = $Background/ScrollContainer/RecipeGrid
onready var scroll : ScrollContainer = $Background/ScrollContainer
onready var filter_menu = $Background/FilterMenu
onready var fader = $Background/Fader
onready var top_fader = $Background/TopFader
onready var compendium_tooltip = $Info/TooltipCollision

const RECIPE = preload("res://game/main-menu/CompendiumRecipeDisplay.tscn")
const OPENED_POSITION = Vector2(910, 0)
const CLOSED_POSITION = Vector2(-960, 0)
const ENTER_SPEED = 40

var recipe_displays := {}
var is_open = false
var tooltip_enabled = false
var block_tooltips = false

class RecipeSorter:
	static func sort_ascending(a, b):
		if a.combination.grid_size == b.combination.grid_size:
			return a.combination.recipe.name < b.combination.recipe.name
		return a.combination.grid_size < b.combination.grid_size


func _physics_process(dt):
	if is_open:
		rect_position = lerp(rect_position, OPENED_POSITION, ENTER_SPEED*dt)
	else:
		rect_position = lerp(rect_position, CLOSED_POSITION, ENTER_SPEED*dt)
	fader.update_scroll_fading(scroll, dt)
	top_fader.update_scroll_fading(scroll, dt)


func _ready():
	rect_position = CLOSED_POSITION
	populate()


func open():
	is_open = true


func populate():
	var display_array := []
	
	for recipe_id in Profile.known_recipes:
		var display = RECIPE.instance()
		var combination = Combination.new()
		combination.create_from_recipe(RecipeManager.recipes[recipe_id], {})
		display.combination = combination
		recipe_displays[recipe_id] = display
		display_array.append(display)
	
	display_array.sort_custom(RecipeSorter, "sort_ascending")
	
	for display in display_array:
		recipe_grid.add_child(display)
		display.set_combination(display.combination)


func get_compendium_hint_tooltip():
	var tip = {"title": tr("COMPENDIUM"), "text": tr("COMPENDIUM_LEVEL_INFO"),
			"title_image": "res://assets/images/ui/compendium_icon.png",
			"subtitle": ""}
	return tip


func enable_tooltips():
	block_tooltips = false
	for display in recipe_grid.get_children():
		if display.visible:
			display.enable_tooltips()
		else:
			display.disable_tooltips()


func disable_tooltips():
	block_tooltips = true
	for display in recipe_grid.get_children():
		display.disable_tooltips()
	remove_tooltips()


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


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
	is_open = false
	emit_signal("closed")


func _on_TooltipCollision_disable_tooltip():
	if tooltip_enabled:
		remove_tooltips()


func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	
	tooltip_enabled = true
	var tip = get_compendium_hint_tooltip()
	TooltipLayer.add_tooltip(compendium_tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)
