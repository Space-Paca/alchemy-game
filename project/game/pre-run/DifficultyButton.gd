extends Button

onready var pressed_particles = $PressedParticles
onready var hover_particles = $HoverParticles

export(Color) var difficulty_color = Color.red

const PRESSED_PARTICLES_FADE_SPEED = 30
const HOVER_PARTICLES_FADE_SPEED = 20

var pressed_a = 0
var hover_a = 0

func _ready():
	hover_particles.process_material.color = difficulty_color
	pressed_particles.process_material.color = difficulty_color.inverted().darkened(.5)


func _process(delta):
	pressed_particles.modulate.a = lerp(pressed_particles.modulate.a, pressed_a,
			delta * PRESSED_PARTICLES_FADE_SPEED)
	hover_particles.modulate.a = lerp(hover_particles.modulate.a, hover_a,
			delta * HOVER_PARTICLES_FADE_SPEED)


func _on_DifficultyButton_mouse_entered():
	hover_a = 1


func _on_DifficultyButton_mouse_exited():
	hover_a = 0


func _on_DifficultyButton_toggled(button_pressed):
	pressed_a = 1 if button_pressed else 0
