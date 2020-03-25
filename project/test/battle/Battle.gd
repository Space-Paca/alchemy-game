extends Node

onready var Hand = $Hand
onready var Reagents = $Reagents
onready var DrawBag = $DrawBag
onready var DiscardBag = $DiscardBag
onready var Grid = $Grid
onready var PassTurn = $PassTurnButton

func setup_nodes():
	DrawBag.Hand = Hand
	DrawBag.Reagents = Reagents
	DrawBag.DiscardBag = DiscardBag
	Grid.DiscardBag = DiscardBag
	DiscardBag.Reagents = Reagents
	PassTurn.Battle = self

func setup_player():
	#Initial dummy bag
	for _i in range(12):
		var type = ReagentManager.random_type()
		DrawBag.add_reagent(ReagentManager.create_object(type))

func _ready():
	setup_nodes()
	
	setup_player()
	
	#For reasons I don't completely understand, Grid needs some time to	actually
	#place the slots in the correct position. Without this, all reagents will go
	#to the first slot position.
	yield(get_tree().create_timer(1.0), "timeout")

	new_player_turn()

func new_player_turn():
	if not Grid.is_empty():
		Grid.clean_grid()
		yield(Grid, "grid_cleaned")
		
	DrawBag.refill_hand()
	yield(DrawBag,"hand_refilled")

func _input(_event):
	pass
