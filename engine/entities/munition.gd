extends Entity
class_name Munition

enum GUIDANCE {active, passive, wire, dumb, radar, actipass }
enum DEPTH {swim, crawl, surface}
@export var id:String
@export var display_name:String
@export var fired_from:Entity
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
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
