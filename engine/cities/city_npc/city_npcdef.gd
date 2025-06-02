extends Resource #HM!
class_name CityNPCDef

@export var portrait:Texture2D
@export var display_name:String
@export var job:String
@export_multiline var vignettes:Array[String]
@export var faction:String #BC Factions are in the tree, we store their name here as a key
