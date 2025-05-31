@tool

extends Node3D
class_name City
@export var anchor:Planet
var height:float = 100.25 #We can't access GlobalConst in the editor so, 100.25
@export var city_def:CityDef
@export var snap:bool = false
@export var faction:Faction
@onready var interaction:CityInteraction = get_node("CityInteraction")

func _process(_delta: float) -> void:
    if snap == true:
        snap = false
        # Calculate the direction from the sphere's center to the node
        var direction: Vector3 = (position - anchor.position).normalized()
        
        # Calculate a tangential "up" vector
        var up_vector: Vector3 = Vector3(0.0, 1.0, 0.0).cross(direction).normalized()
        
        # Recalculate the tangential vector to ensure it's perpendicular to the direction
        up_vector = direction.cross(up_vector).normalized()
        
        # Use the custom up vector in the look_at function
        look_at(anchor.position, up_vector)
         # Rotate 90 degrees around the custom up vector
 
        fix_height()


func _ready():
    var faction_to_find = city_def.default_faction_id
    faction = get_tree().root.find_child("Factions", true, false).get_node(faction_to_find)
    print("Hello from ", name, " my faction is ", faction.name)
    
    interaction.unpack(faction)


func fix_height()->void:
    #The  entity should always be 5 above the tangential surface of the anchor.
    #If tne anchor has a radius of 100m, the entity shall sit at 100.25, but not otherwise modify its position.
    #A higher height will be more permissive when colliding with the map
    var direction:Vector3 = (position - anchor.position).normalized()
    var desired_position:Vector3 = anchor.position + (direction * height)
    position = desired_position
    pass

func do_snap():
    snap = true
