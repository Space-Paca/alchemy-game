extends Control

signal hint_bought(combination)
signal bought(combination)

onready var buy_button = $VBoxContainer/Buy
onready var hint_button = $VBoxContainer/Hint
onready var recipe_display = $RecipeDisplayBig

const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")
const HINT_COST_RATIO = .6

var combination : Combination
var player : Player
var buy_cost : int
var hint_cost : int


func set_combination(_combination: Combination):
	combination = _combination
	recipe_display.set_combination(combination)
	
	update_display()


func update_display():
	recipe_display.update_combination()
	
	buy_cost = combination.recipe.shop_cost
	hint_cost = int(ceil(buy_cost * HINT_COST_RATIO))
	for i in combination.hints:
		buy_cost /= 2
		hint_cost /= 2
	
	buy_button.text = tr("BUY_RECIPE")+" (%d)" % buy_cost
	hint_button.text = tr("BUY_HINT")+" (%d)" % hint_cost
	
	if combination.discovered:
		buy_button.disabled = true
		hint_button.visible = false
		buy_button.text = "ALREADY_KNOWN"
	elif combination.hints >= 2:
		hint_button.disabled = true
		hint_button.text = "BUY_HINT"


func enable_tooltips():
	recipe_display.enable_tooltips()


func disable_tooltips():
	recipe_display.disable_tooltips()


func _on_Buy_pressed():
	if player.spend_gold(buy_cost):
		AudioManager.play_sfx("buy")
		combination.discover_all_reagents("shop")
		update_display()
		emit_signal("bought", combination)
	else:
		AudioManager.play_sfx("error")


func _on_Hint_pressed():
	if player.spend_gold(hint_cost):
		combination.get_hint("shop")
		update_display()
		AudioManager.play_sfx("discover_clue_recipe")
		emit_signal("hint_bought", combination)
	else:
		AudioManager.play_sfx("error")
