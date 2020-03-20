extends Node

const REAGENT = preload("res://test/reagents/Reagent.tscn")

func create(type):
	return REAGENT.instance()
