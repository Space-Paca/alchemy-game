extends TextureRect

var type : String
var tooltips_enabled := false
var block_tooltips := false

const BASE_WIDTH = 64
const BASE_HEIGHT = 64

func init(_type: String):
	type = _type
	var data = ArtifactDB.get_from_name(type)
	texture = data.image
	update_size(1.0)


func update_size(scale: float):
	var w = BASE_WIDTH*scale
	var h = BASE_HEIGHT*scale
	rect_size = Vector2(w,h)
	update_tooltip_collision()

func update_tooltip_collision():
	var w = rect_size.x * rect_scale.x
	var h = rect_size.y * rect_scale.x
	$TooltipCollision.global_position.x = rect_global_position.x + w/2
	$TooltipCollision.global_position.y = rect_global_position.y + h/2
	$TooltipCollision.set_collision_width(w)
	$TooltipCollision.set_collision_height(h)

func disable():
	block_tooltips = true
	disable_tooltips()

func enable():
	block_tooltips = false

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
	var tooltip = ArtifactDB.get_tooltip(type)
	TooltipLayer.add_tooltip($TooltipCollision.get_position(), tooltip.title, \
							 tooltip.text, tooltip.title_image, tooltip.subtitle, true)
