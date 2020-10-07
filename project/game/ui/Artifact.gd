extends Control

var type : String
var tooltips_enabled := false
var block_tooltips := false

const BASE_WIDTH = 64
const BASE_HEIGHT = 64

func init(_type: String):
	type = _type
	var data = ArtifactDB.get_from_name(type)
	$Image.texture = data.image
	update_size(1.0)


func update_size(scale: float):
	var w = BASE_WIDTH*scale
	var h = BASE_HEIGHT*scale
	$Image.rect_size = Vector2(w,h)
	$TooltipCollision.position.x = w/2
	$TooltipCollision.position.y = h/2
	$TooltipCollision.set_collision_width(w)
	$TooltipCollision.set_collision_height(h)
	$TooltipPosition.position.x = w + 5
	$TooltipPosition.position.y = 0

func disable():
	block_tooltips = true
	disable_tooltips()

func enable():
	block_tooltips = false

func get_self_tooltip():
	var tooltip = {}
	var data = ArtifactDB.get_from_name(type)
	tooltip.title = data.name
	tooltip.text = data.description
	tooltip.title_image = data.image
	
	return tooltip

func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()

func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	tooltips_enabled = true
	var tooltip = get_self_tooltip()
	TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, true)
