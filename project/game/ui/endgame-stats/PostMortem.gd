extends Control

export var sketch_color : Color
export var poison_texture : Texture

const ARTIFACT = preload("res://game/ui/Artifact.tscn")
const CLICKABLE_REAGENT = preload("res://game/ui/ClickableReagent.tscn")

func _ready():
	$Killer/Name.set("custom_colors/font_color", sketch_color)
	$Killer/Image.material.set_shader_param("outline_color", sketch_color)


func set_player(p: Player):
	if not p.what_killed_me:
		pass
	elif p.what_killed_me.source != p:
		$Killer/Name.text = p.what_killed_me.source.data.name
		$Killer/Image.texture = load(p.what_killed_me.source.data.image)
	elif p.what_killed_me.type == "poison":
		$Killer/Name.text = "POISON"
		$Killer/Image.texture = poison_texture
	
	$PlayerInfo/VBoxContainer/HBoxContainer/GoldLabel.text = str(p.gold)
	$PlayerInfo/VBoxContainer/HBoxContainer2/PearlLabel.text = str(p.pearls)
	
	set_reagents(p.bag)
	set_artifacts(p.artifacts)


func set_reagents(bag: Array):
	var reagent_container = $Bag/ScrollContainer/ReagentContainer
	for child in reagent_container.get_children():
		reagent_container.remove_child(child)
	
	for reagent in bag:
		var clickable_reagent = CLICKABLE_REAGENT.instance()
		var texture = ReagentDB.get_from_name(reagent.type).image
		clickable_reagent.setup(texture, reagent.upgraded, reagent.type)
		reagent_container.add_child(clickable_reagent)


func set_artifacts(artifacts: Array):
	if artifacts.empty():
		$PlayerInfo/Panel/Label.show()
		return
	
	var container = $PlayerInfo/Panel/ScrollContainer/GridContainer
	for child in container.get_children():
		container.remove_child(child)
	
	for artifact_name in artifacts:
		var artifact = ARTIFACT.instance()
		container.add_child(artifact)
		artifact.init(artifact_name)
