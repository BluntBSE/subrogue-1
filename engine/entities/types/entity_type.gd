extends Resource
class_name EntityType

enum munitition_types {torpedoes, missiles, all}
@export var id:String
@export var display_class:String #Submarine, Commercial Vessel, etc
@export var category:String
#STRUCTURE
@export var base_hull:int
@export var base_cargo:int
#WEAPONS AND UPGRADES
@export var munition_types:int #Of an ENUM of 
@export var munition_slots:int #Number of distinct munitions
@export var munition_size:int
@export var utility_slots:int
@export var utility_size:int
@export var upgrade_slots:int
#VISUALS
@export var sprite:Texture2D
@export var inspection_scene:PackedScene
#@export var model
#NAVIGATION
@export var base_max_speed:int
@export var base_profile:float #From 0 to 1.0, how much like a military target does this thing look like?
@export var base_pitch:float 
@export var base_volume:float
@export var base_min_sensitivity:float
@export var base_max_sensitivity:float
@export var base_min_certainty:float
@export var size:float #How big is the object in m3?

@export var vol_speed_factor:float
#{swim, crawl, surface}
@export var depths:Array #accepts enums
@export var current_depth:int

#AI
@export var behavior_type:BehaviorType

#META
@export var base_cost:int
