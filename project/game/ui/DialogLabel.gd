extends RichTextLabel

const DIALOG_SPEED := 25
const DIALOG_SPEED_MOD := [1.0, 8.0, 100.0]
const ALTERNATIVE_SPEED_MOD := {
	"fast": .4,
	"slow": 3.5,
}
const WAIT_TIME := 0.3
const SHORT_WAIT_TIME := 0.15
const LONG_WAIT_TIME := 1.0

var dialog_to_use = ""
var current_dialog_speed = 0
var alternative_speed_mod = 1.0


func reset():
	dialog_to_use = ""
	current_dialog_speed = 0
	alternative_speed_mod = 1.0
	bbcode_text = ""


func speed_up_dialog():
	 if dialog_to_use.length() > 0:
			current_dialog_speed = min(current_dialog_speed+1, DIALOG_SPEED_MOD.size()-1)


func start_dialog(dialog):
	dialog_to_use = dialog
	advance_dialogue()


func advance_dialogue():
	if dialog_to_use[0] == '[':
		if dialog_to_use[1] == '/':
			if dialog_to_use.begins_with("[/slow]") or dialog_to_use.begins_with("[/fast]"):
				alternative_speed_mod = 1.0
			else:
				pop()
				
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
						yield(get_tree().create_timer(WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[shortwait]":
						yield(get_tree().create_timer(SHORT_WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[longwait]":
						yield(get_tree().create_timer(LONG_WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[slow]":
						alternative_speed_mod = ALTERNATIVE_SPEED_MOD.slow
					elif effect == "[fast]":
						alternative_speed_mod = ALTERNATIVE_SPEED_MOD.fast
					else:
						# warning-ignore:return_value_discarded
						append_bbcode(effect)
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
	
