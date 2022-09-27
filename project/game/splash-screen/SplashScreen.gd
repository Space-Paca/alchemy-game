extends Control


func _ready():
	$ChooseLanguage.hide()
	yield(get_tree(), "idle_frame")
	Debug.set_version_visible(true)
	FileManager.load_game()
	if Profile.get_option("choose_language"):
		var locale = Profile.LANGUAGES[Profile.get_option("locale")].locale
		TranslationServer.set_locale(locale)
		$ChooseLanguage.hide()
		yield(get_tree().create_timer(1.0), "timeout")
		Transition.transition_to("res://game/main-menu/MainMenu.tscn")
	else:
		$ChooseLanguage.show()


func _on_button_pressed(locale):
	var idx = Profile.get_locale_idx(locale)
	Profile.set_option("locale", idx)
	TranslationServer.set_locale(locale)
	Profile.set_option("choose_language", true)
	FileManager.save_profile()
	$ChooseLanguage.hide()
	yield(get_tree().create_timer(1.0), "timeout")
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")
