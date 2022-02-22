extends RichTextLabel

export(String, "shop", "smith") var voice_name:= "shop"
export var amount_of_voices : int

const SFX_PATH = "res://database/audio/sfxs/"
const PLAY_SOUND_INTERVAL = 2
const DIALOG_SPEED := 25
const DIALOG_SPEED_MOD := [1.0, 8.0, 100.0]
const ALTERNATIVE_SPEED_MOD := {
	"fast": .55,
	"slow": 3.5,
	"normal": 1.0,
}
const WAIT_TIME := 0.3
const SHORT_WAIT_TIME := 0.15
const LONG_WAIT_TIME := 1.0

var alphanumeric = RegEx.new()
var dialog_to_use = ""
var current_dialog_speed = 0
var alternative_speed_mod = ALTERNATIVE_SPEED_MOD.normal
var play_sound = true
var effects_stack = []


func _ready():
	alphanumeric.compile("[A-Za-z0-9À-ÖØ-öø-ÿ]")


func reset():
	dialog_to_use = ""
	current_dialog_speed = 0
	alternative_speed_mod = 1.0
	bbcode_text = ""
	effects_stack = []
	play_sound = true


func speed_up_dialog():
	 if dialog_to_use.length() > 0:
			current_dialog_speed = min(current_dialog_speed+1, DIALOG_SPEED_MOD.size()-1)


func start_dialog(dialog):
	dialog_to_use = dialog
	advance_dialogue()


func get_pitch():
	var pitch = 1.0
	if alternative_speed_mod == ALTERNATIVE_SPEED_MOD.slow:
		pitch = .7
	elif alternative_speed_mod == ALTERNATIVE_SPEED_MOD.fast:
		pitch = 1.5
	
	if effects_stack.has("[shake]"):
		pitch += rand_range(-.3, .3)
	if effects_stack.has("[wave]"):
		pitch += sin(OS.get_ticks_msec()*.5)*.2 +.4
	if effects_stack.has("[i]"):
		pitch += .25
		
	return pitch


func get_volume():
	var volume = 0.0
	if effects_stack.has("[i]"):
		volume = -6.0
		
	elif dialog_to_use[0] == dialog_to_use[0].to_upper():
		volume = 4.0
	
	return volume


func advance_dialogue():
	if dialog_to_use[0] == '[':
		if dialog_to_use[1] == '/':
			if dialog_to_use.begins_with("[/slow]") or dialog_to_use.begins_with("[/fast]"):
				alternative_speed_mod = 1.0
			else:
				pop()
				effects_stack.pop_front()
				
			while dialog_to_use[0] != ']':
				dialog_to_use = dialog_to_use.substr(1, -1)
			dialog_to_use = dialog_to_use.substr(1, -1)
		else:
			var found = false
			for effect in ["[shake]", "[wave]", "[i]",\
						   "[wait]", "[shortwait]", "[longwait]",\
						   "[slow]", "[fast]"]:
				if dialog_to_use.begins_with(effect):
					found = true
					if effect == "[wait]":
						play_sound = PLAY_SOUND_INTERVAL*DIALOG_SPEED_MOD[current_dialog_speed]
						yield(get_tree().create_timer(WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[shortwait]":
						play_sound = PLAY_SOUND_INTERVAL*DIALOG_SPEED_MOD[current_dialog_speed]
						yield(get_tree().create_timer(SHORT_WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[longwait]":
						play_sound = PLAY_SOUND_INTERVAL*DIALOG_SPEED_MOD[current_dialog_speed]
						yield(get_tree().create_timer(LONG_WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[slow]":
						alternative_speed_mod = ALTERNATIVE_SPEED_MOD.slow
					elif effect == "[fast]":
						alternative_speed_mod = ALTERNATIVE_SPEED_MOD.fast
					else:
						# warning-ignore:return_value_discarded
						append_bbcode(effect)
						effects_stack.push_front(effect)
					dialog_to_use = dialog_to_use.trim_prefix(effect)
					break
			if not found:
				push_error("Not a valid effect: " + dialog_to_use)
				while dialog_to_use[0] != ']':
					dialog_to_use = dialog_to_use.substr(1, -1)
				dialog_to_use = dialog_to_use.substr(1, -1)
	else:
		# warning-ignore:return_value_discarded
		append_bbcode(dialog_to_use[0])
		if alphanumeric.search(dialog_to_use[0]):
			if play_sound == PLAY_SOUND_INTERVAL*DIALOG_SPEED_MOD[current_dialog_speed]:
				var sample = "voice_"+voice_name+"_"+str(randi()%amount_of_voices + 1)	
				AudioManager.play_sfx(sample, get_pitch(), get_volume())
				
				if alternative_speed_mod == ALTERNATIVE_SPEED_MOD.normal:
					play_sound = 0
			else:
				play_sound = min(play_sound + 1, PLAY_SOUND_INTERVAL*DIALOG_SPEED_MOD[current_dialog_speed])
		else:
			play_sound = PLAY_SOUND_INTERVAL*DIALOG_SPEED_MOD[current_dialog_speed]
			#Play ponctuation sound if currently on a '...'
			if dialog_to_use[0] == '.' and \
			   ((dialog_to_use.length() > 1 and dialog_to_use[1] == '.') or\
			   (text.length() > 0 and text[text.length() - 1] == '.')):
				var sample = "voice_"+voice_name+"_punctuation"
				AudioManager.play_sfx(sample, get_pitch(), get_volume())
				
		dialog_to_use = dialog_to_use.substr(1, -1)
	if dialog_to_use.length() > 0:
		if current_dialog_speed == DIALOG_SPEED_MOD.size() - 1:
			complete_dialog()
		else:
			yield(get_tree().create_timer(alternative_speed_mod/(DIALOG_SPEED*DIALOG_SPEED_MOD[current_dialog_speed])), "timeout")
			advance_dialogue()


func complete_dialog():
	for keyword in ["[wait]", "[shortwait]", "[longwait]", \
					"[slow]", "[/slow]", "[fast]", "[/fast]"]:
		dialog_to_use = dialog_to_use.replace(keyword, "")
	# warning-ignore:return_value_discarded	
	append_bbcode(dialog_to_use)
	dialog_to_use = ""
	
