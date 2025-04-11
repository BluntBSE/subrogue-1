extends Node3D
class_name Player

@onready var markers:PlayerMarkers = get_node("PlayerMarkers")

#@onready var selected = [%PlayerEntity] #Selection is not a feature of the game for now.
@onready var camera:OrbitalCamera = get_node("PlayerCameras/OrbitalCamera")
@onready var UI:PlayerUIRoot = get_node("CanvasLayer/PlayerUIRoot")
@onready var entities:PlayerEntities = get_node("PlayerEntities")
@export var visible_layers=[2,5]#Defaults to "all entities" and "player 1"
var layer = GlobalConst.layers.PLAYER_1 #At some point we'll need to set this in code for multiple players
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #We put child nodes unpacks here so all the parent data can be set first
    %OrbitalCamera.unpack()
    %PlayerMarkers.unpack()
    %PlayerEntities.unpack()
    UI.unpack()
    camera.camera_moved.connect(UI.adjust_ruler)
    #Only do this if the game has not started before.
    entities.get_node("PlayerEntity").position = determine_spawn_point().position
    camera.make_current()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func determine_spawn_point()->Node3D:
    var spawn_str = "player_" + str(get_multiplayer_authority())
    var spawn_nodes = get_tree().root.find_child("PlayerSpawnNodes",true,false)
    var spawn_node = spawn_nodes.find_child(spawn_str)
    return spawn_node
    
