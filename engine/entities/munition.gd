extends Entity
class_name Munition

enum GUIDANCE {active, passive, wire, dumb, radar, actipass }
enum DEPTH {swim, crawl, surface}
@export var id:String
@export var display_name:String
@export var fired_from:Entity
@export var munition_type:String
@export var guidance_type: int #accepts GUIDANCE enums
@export var impact_radius:float
@export var fuel_remaining:float
@export var fuel_max:float
@export var fuel_burn:float
@export var current_depth:int #accepts DEPTH enums
@export var target_depths:Array #accepts DEPTH enums
@export var target_pos:Vector3
@export var target_node:Node3D
@export var sprite_override:Texture2D
#PASSIVE SONAR PARAMETERS
@export var tracking_angle:float
@export var tracking_range:float
#@export var activate_after:float #distance to travel before turning on...

"""
    fired from
    heading to
    type ENUM { torpedo, missile}
    guidance_type ENUM { active, wireguide, passive, dumb}
    radius
    range
    speed
    fuel
    fuel_burn
    depth - array of ENUM {surface, swim, crawl}

    targeting parameters - based on ENUM
    passive:
    turn on after X distance
    max_angle
    target_hz
    <SPECIAL> self pitch hz
    <SPECIAL> variable speed(?)    
"""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    faction = fired_from.faction
    render.update_mesh_visibilities(faction, true)
    
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float)->void:
    var mesh_1:MeshInstance3D = %TrackingConeMesh
    var entity:Munition = self
    var up = (entity.anchor.position - entity.position).normalized()
    #This, along wth the funky rotations on the mesh, are how we keep the plane from clipping into the planet.
    mesh_1.look_at(entity.anchor.position)
    mesh_1.rotation.z += deg_to_rad(90.0)
    mesh_1.rotation.z += rotation.z
