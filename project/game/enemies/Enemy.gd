extends Character

signal acted

const HEALTH_BAR_MARGIN = 10

var logic_

func act():
	var state = logic_.get_current_state()
	print(state+"!")
	$AnimationPlayer.play("attack")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")
	emit_signal("acted")
	state = logic_.update_state()
	print("new state: " + state)

func setup(enemy_logic, new_texture):
	set_logic(enemy_logic)
	set_max_hp()
	set_image(new_texture)

func set_logic(enemy_logic):
	logic_ = load("res://game/enemies/EnemyLogic.gd").new()
	
	for state in enemy_logic.states:
		logic_.add_state(state)
	for link in enemy_logic.connections:
		logic_.add_connection(link[0], link[1], link[2])
	
	#Get random first state
	randomize()
	enemy_logic.first_state.shuffle()
	logic_.set_state(enemy_logic.first_state.front())


func set_max_hp():
	$HealthBar.max_value = max_hp
	$HealthBar.value = max_hp
	
func set_image(new_texture):
	$TextureRect.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN

func get_width():
	return $TextureRect.texture.get_width()

func get_height():
	return $TextureRect.texture.get_height()
