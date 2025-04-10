extends Node3D
class_name Player

@onready var markers:PlayerMarkers = get_node("PlayerMarkers")
var anchor:Planet
var spawn_point:Node3D
@onready var selected = [%PlayerEntity] #Selection is not a feature of the game for now.
@onready var camera:OrbitalCamera = get_node("PlayerCameras/OrbitalCamera")
@onready var UI:PlayerUIRoot = get_node("CanvasLayer/PlayerUIRoot")
@onready var entities:PlayerEntities = get_node("PlayerEntities")
@export var visible_layers=[2,5]#Defaults to "all entities" and "player 5"
var layer = GlobalConst.layers.PLAYER_1 #At some point we'll need to set this in code for multiple players
# Called when the node enters the scene tree for the first time.

@rpc("any_peer", "call_local")
func unpack(_anchor, _spawn_point):
    pass


func _ready() -> void:
    configure_sub_nodes(anchor, spawn_point)
    camera.camera_moved.connect(UI.adjust_ruler)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
 #Needs to be rpcd, wow.
func configure_sub_nodes(anchor, spawn_node):
    var entity:Entity = %PlayerEntity
    entity.position = spawn_node.position
    entity.unpack(anchor, "debug_commercial", layer)
    
    var camera:OrbitalCamera = %OrbitalCamera
    camera.unpack(self, anchor, layer)
    camera.position = entity.position
    
    var controller:PlayerEntities = %PlayerEntities
    controller.unpack(camera)
    
    var ui:PlayerUIRoot = %PlayerUIRoot
    ui.unpack(camera, anchor)
    
func start_at(anchor:Planet, spawn_node:Node):
    pass

    
