extends Control

export var sketch_color : Color
export var poison_texture : Texture

const CLICKABLE_REAGENT = preload("res://game/ui/ClickableReagent.tscn")

func _ready():
	$Killer/Name.set("custom_colors/font_color", sketch_color)
	$Killer/Image.material.set_shader_param("outline_color", sketch_color)


func set_player(p: Player):
	if p.what_killed_me.source != p:
		$Killer/Name.text = p.what_killed_me.source.data.name
		$Killer/Image.texture = load(p.what_killed_me.source.data.image)
	elif p.what_killed_me.type == "poison":
		$Killer/Name.text = "Poison"
		$Killer/Image.texture = poison_texture
	
	set_reagents(p.bag)


func set_reagents(bag: Array):
	var reagent_container = $ScrollContainer/ReagentContainer
	for child in reagent_container.get_children():
		reagent_container.remove_child(child)

	for reagent in bag:
		var clickable_reagent = CLICKABLE_REAGENT.instance()
		var texture = ReagentDB.get_from_name(reagent.type).image
		clickable_reagent.setup(texture, reagent.upgraded, reagent.type)
		reagent_container.add_child(clickable_reagent)
