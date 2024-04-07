extends Button

const MUTE_DB = -60
const SFX_SPEED = 320
const MAX_DB = 15

onready var particles = $Particles2D
onready var anim = $AnimationPlayer
onready var hover_sfx = $HoverSFX
onready var portrait = $Portrait

var mouse_in = false

func _ready():
	hover_sfx.volume_db = MUTE_DB
	if pressed:
		start_particles()


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and\
			event.pressed:
		if disabled:
			anim.play("error")
			AudioManager.play_sfx("error")


func _process(dt):
	if mouse_in and not pressed:
		hover_sfx.volume_db = min(hover_sfx.volume_db + SFX_SPEED*dt, MAX_DB)
	else:
		hover_sfx.volume_db = max(hover_sfx.volume_db - .6*SFX_SPEED*dt, MUTE_DB)
	
	if hover_sfx.volume_db > MUTE_DB and not hover_sfx.playing:
		hover_sfx.play(rand_range(0.0, hover_sfx.stream.get_length()))
	elif hover_sfx.volume_db <= MUTE_DB and hover_sfx.playing:
		hover_sfx.stop()


func set_unlocked(unlocked):
	disabled = not unlocked
	if unlocked:
		portrait.set_material(null)


func set_portrait(texture):
	portrait.texture = texture


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
	AudioManager.play_sfx("select_character")
