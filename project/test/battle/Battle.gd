extends Node

const REAGENT = preload("res://test/battle/Reagent.tscn")

onready var Hand = $Hand
onready var Reagents = $Reagents
onready var DrawBag = $DrawBag
onready var DiscardBag = $DiscardBag
onready var Grid = $Grid

func setup_nodes():
	DrawBag.Hand = Hand
	DrawBag.Reagents = Reagents
	DrawBag.DiscardBag = DiscardBag
	Grid.DiscardBag = DiscardBag
	DiscardBag.Reagents = Reagents

func setup_player():
	#Initial dummy bag
	for _i in range(12):
		DrawBag.add_reagent(REAGENT.instance())

func _ready():
	setup_nodes()
	
	setup_player()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_N:
			DrawBag.refill_hand()
