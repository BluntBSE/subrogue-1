extends Resource
class_name EntityType

enum munitition_types {torpedoes, missiles, all}
@export var id:String
@export var display_name:String
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
#@export var model
#NAVIGATION
@export var base_max_speed:int
@export var base_profile:float #From 0 to 1.0, how much like a military target does this thing look like?
@export var base_pitch:float 
@export var base_volume:float

@export var vol_speed_factor:float
#{swim, crawl, surface}
@export var depths:Array #accepts enums
@export var current_depth:int
#DETECTION
@export var base_passive_sensitivity:float #Range at which a 90DB,60hz sound will be identified with 100% certainty. 
@export var base_active_max_volume:int #Db
#META
@export var base_cost:int
