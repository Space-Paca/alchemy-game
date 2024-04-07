extends Node

# Steam variables
onready var Steam = preload("res://addons/godotsteam/godotsteam.gdns").new()

var is_free_weekend: bool = false
var is_owned: bool = false
var is_online: bool = false
var is_on_steam_deck: bool = false
var steam_app_id: int = 1960330
var steam_id: int = 0
var steam_username: String = ""


# Set your game's Steam app IP
func _init() -> void:
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))


func _ready() -> void:
	# Initialize Steam
	var initialize_response: Dictionary = Steam.steamInit(false)
	print("[STEAM] Did Steam initialize?: %s" % initialize_response)
	if initialize_response['status'] != 1:
		# If Steam fails to start up, shut down the app
		print("[STEAM] Failed to initialize Steam: %s" % initialize_response['verbal'])
	else:
		Debug.is_steam = true
	
	
#	#Is the user online?
#	is_online = Steam.loggedOn()
#
#	# Get the user's Stean name and ID
#	steam_id = Steam.getSteamID()
#	steam_username = Steam.getPersonaName()
#
#	# Is this app owned or is it a free weekend?
#	is_owned = Steam.isSubscribed()
#	is_free_weekend = Steam.isSubscribedFromFreeWeekend()
#
#	# Is the game running on the Steam Deck
#	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()


func _process(_delta: float) -> void:
	# Get callbacks
	Steam.run_callbacks()


func set_achievement(ach_name: String) -> void:
	var _was_set: bool = Steam.setAchievement(ach_name)
	Steam.storeStats()


func set_rich_presence(string: String, token = false) -> void:
	if not Debug.is_steam:
		return
	if token:
		Steam.setRichPresence(token, string)
	else:
		Steam.setRichPresence("steam_display", string)
