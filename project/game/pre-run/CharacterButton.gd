extends Button

onready var particles = $Particles2D
onready var anim = $AnimationPlayer

var mouse_in = false

func _ready():
	if pressed:
		start_particles()


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and\
			event.pressed:
		if disabled:
			anim.play("error")


func start_particles():
	if particles.emitting:
		return
	
	particles.emitting = true
	yield(get_tree().create_timer(.1), "timeout")
	particles.speed_scale = 1


func stop_particles():
	if pressed:
		return
	
	particles.emitting = false
	particles.speed_scale = 5


func _on_Button_mouse_entered():
	mouse_in = true
	start_particles()


func _on_Button_mouse_exited():
	mouse_in = false
	stop_particles()


func _on_Button_toggled(button_pressed):
	if not particles:
		return
	
	if button_pressed:
		start_particles()
	else:
		stop_particles()


func _on_Button_pressed():
	print('aa')


func _on_StartButton_pressed():
	pass # Replace with function body.


func _on_BackButton_pressed():
	pass # Replace with function body.
