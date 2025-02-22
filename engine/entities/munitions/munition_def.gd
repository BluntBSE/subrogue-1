extends Resource
class_name MunitionDef
"""
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
"""


@export var id: String
@export var display_name: String
## enum GUIDANCE {active, passive, wire, dumb, radar, actipass }
@export var guidance_type: int # accepts GUIDANCE enums
@export var impact_radius: float #In what units?
@export var fuel_remaining: float
@export var fuel_max: float
@export var fuel_burn: float
## enum DEPTH {swim, crawl, surface}
@export var current_depth: int # accepts DEPTH enums
## enum DEPTH {swim, crawl, surface}
@export var target_depths: Array[int] # accepts DEPTH enums
@export var target_pos: Vector3
@export var sprite_override: Texture2D
@export var max_speed: float
@export var trauma:float
