extends Node
#Acessed as Autoload as SteamManager
var is_owned:bool = false #Do they own the game? Who cares!
var steam_app_id:int = 480 #Spacewar debug ID
var steam_id:int = 0 #I think this is the user
var steam_username:String = ""
var lobby_id = 0
var lobby_max_players = 6

func _init()->void:
    print("Initializing Steam")
    #What's the difference between AppID and GameID?
    OS.set_environment("SteamAppID", str(steam_app_id))
    OS.set_environment("SteamGameID", str(steam_app_id))

func _process(delta:float)->void:
    Steam.run_callbacks()

func initialize_steam():
    var initialize_response:Dictionary = Steam.steamInitEx()
    print ("Did steam initialize? %s" % initialize_response)
    if initialize_response['status'] > 0:
        print("Steam did not initialize! Perish, fool")
        get_tree().quit()
    
    #is_owned = Steam.isSubscribed()
    steam_id = Steam.getSteamID()
    steam_username = Steam.getPersonaName()
    
    print("steam_id is %s" % steam_id)
