extends Node

var Battle = null #Set by parent

func _on_PassTurnButton_pressed():
	Battle.new_enemy_turn()
