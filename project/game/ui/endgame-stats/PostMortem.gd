extends Control

func _ready():
	pass


func set_player(p: Player):
	if p.what_killed_me.source != p:
		$Killer/Name.text = p.what_killed_me.source.data.name
		$Killer/Image.texture = load(p.what_killed_me.source.data.image)
