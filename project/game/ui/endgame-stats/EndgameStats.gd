extends Control

var player : Player


func _ready():
	pass


func set_player(p: Player):
	player = p
	$CompendiumProgress.set_player(p)
