extends Node

const REAGENT = preload("res://test/battle/Reagent.tscn")

onready var Hand = $Hand
onready var Reagents = $Reagents
onready var DrawBag = $DrawBag
onready var DiscardBag = $DiscardBag

func setup_nodes():
	DrawBag.Hand = Hand
	DiscardBag.Hand = Hand
	DrawBag.Reagents = Reagents
	DiscardBag.Reagents = Reagents

func setup_player():
	#Initial dummy bag
	for _i in range(100):
		DrawBag.add_reagent(REAGENT.instance())

func _ready():
	setup_nodes()
	
	setup_player()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			DrawBag.refill_hand()
