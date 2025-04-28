extends Faction
class_name Player

@onready var markers:PlayerMarkers = get_node("PlayerMarkers")

#@onready var selected = [%PlayerEntity] #Selection is not a feature of the game for now.
@onready var camera:OrbitalCamera = get_node("PlayerCameras/OrbitalCamera")
@onready var UI:PlayerUIRoot = get_node("UICanvas/PlayerUIRoot")
@onready var entities:PlayerEntities = get_node("PlayerEntities")
var visible_layers=[]
var faction:Faction = self #At some point we'll need to set this in code for multiple players
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    faction_color = Color("00aea8") #At least until we decide how to sync these. Or not. Honestly
    #You could put NPC synchronizers on the factions and not the player factions
    #We put child nodes unpacks here so all the parent data can be set first
    %OrbitalCamera.unpack()
    %PlayerMarkers.unpack()
    %PlayerEntities.unpack()
    UI.unpack()
    camera.camera_moved.connect(UI.adjust_ruler)
    #Only do this if the game has not started before.
    entities.get_node("PlayerEntity").position = determine_spawn_point().position
    entities.get_node("PlayerEntity").unpack("player_sub", faction, null)
    camera.make_current()
    if is_multiplayer_authority():
        get_node("UICanvas").visible = true
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func determine_spawn_point()->Node3D:
    var peer = get_multiplayer_authority()
    var game_root:GameRoot = get_tree().root.find_child("GameRoot", true, false)
    for player in game_root.players.keys():#Assumes spawn points match the keys of the player
        if game_root.peers[player] == peer:    
            var spawn_nodes = get_tree().root.find_child("PlayerSpawnNodes",true,false)
            var spawn_node = spawn_nodes.find_child(player)
            return spawn_node
    print("ERORR! could not find a spawn node for ", self.name)
    return null
    
func set_faction_ids():
    #Override the faction version of this to do nothing because players are set up at the very, very, beginning by the globe scene.
    pass


func _on_console_input_text_submitted(new_text: String) -> void:
    pass # Replace with function body.
