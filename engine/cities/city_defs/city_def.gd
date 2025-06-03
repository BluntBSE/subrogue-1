extends Resource
class_name CityDef

@export var city_name:String
@export var default_faction_id:String
@export_multiline var city_greeting:String
@export var city_portrait:Texture2D
@export var default_npcs:Array[CityNPCDef] #If NPCs eventually move, we might need to revisit this and make NPCs exist as nodes. But for now, this is fine.
