extends Button

const MUTE_DB = -60
const SFX_SPEED = 270
const MAX_DB = 17

onready var pressed_particles = $PressedParticles
onready var hover_particles = $HoverParticles
onready var hover_sfx = $HoverSFX
export var skip_sfx = false

export(Color) var difficulty_color = Color.red

const PRESSED_PARTICLES_FADE_SPEED = 30
const HOVER_PARTICLES_FADE_SPEED = 20

var pressed_a = 0
var hover_a = 0

func _ready():
	#Gambiarra to make hardest difficulty sfx not play at startup but work after
	if skip_sfx:
		skip_sfx = false 
	hover_sfx.volume_db = MUTE_DB
	hover_particles.process_material.color = difficulty_color
	pressed_particles.process_material.color = difficulty_color.inverted().darkened(.5)


func _process(delta):
	pressed_particles.modulate.a = lerp(pressed_particles.modulate.a, pressed_a,
			delta * PRESSED_PARTICLES_FADE_SPEED)
	hover_particles.modulate.a = lerp(hover_particles.modulate.a, hover_a,
			delta * HOVER_PARTICLES_FADE_SPEED)
	
	#Hover sfx
	if hover_a:
		hover_sfx.volume_db = min(hover_sfx.volume_db + SFX_SPEED*delta, MAX_DB)
	else:
		hover_sfx.volume_db = max(hover_sfx.volume_db - .6*SFX_SPEED*delta, MUTE_DB)
	
	if hover_sfx.volume_db > MUTE_DB and not hover_sfx.playing:
		hover_sfx.play(rand_range(0.0, hover_sfx.stream.get_length()))
	elif hover_sfx.volume_db <= MUTE_DB and hover_sfx.playing:
		hover_sfx.stop()


func _on_DifficultyButton_mouse_entered():
	hover_a = 1


func _on_DifficultyButton_mouse_exited():
	hover_a = 0


func _on_DifficultyButton_toggled(button_pressed):
	pressed_a = 1 if button_pressed else 0
	if pressed_a:
		if skip_sfx:
			skip_sfx = false
		else:
			AudioManager.play_sfx("select_difficulty")
