extends Control


func _ready():
	yield(get_tree(), "idle_frame")
	Debug.set_version_visible(true)
	if Profile.get_option("choose_language"):
		yield(get_tree().create_timer(1.0), "timeout")
		Transition.transition_to("res://game/main-menu/MainMenu.tscn")
	else:
		$ChooseLanguage.show()


func _on_button_pressed(locale):
	var idx = Profile.LANGUAGES.find(locale)
	Profile.set_option("locale", idx)
	TranslationServer.set_locale(locale)
	Profile.set_option("choose_language", true)
	$ChooseLanguage.hide()
	yield(get_tree().create_timer(1.0), "timeout")
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")
