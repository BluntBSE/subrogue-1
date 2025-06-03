@tool

extends Node3D
class_name City
@export var anchor:Planet
var height:float = 100.25 #We can't access GlobalConst in the editor so, 100.25
@export var city_def:CityDef
@export var snap:bool = false
@export var faction:Faction
@export var instanced_npcs:Array
@onready var interaction:CityInteraction = get_node("CityInteraction")
@export var npcs:Array[CityNPC]
@export var npc_node:Node #Just holds them in the tree.

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
    
    interaction.unpack(faction)
    #TODO: NPCs
    npc_node = Node.new()
    npc_node.name = "NPCs"
    add_child(npc_node)
    #This isn't the way to do it but...whatever. Prototyping what the city scene should even be in the end.
    if get_node("NPCs") == null:
        npc_node = Node.new()
        npc_node.name = "NPCs"
        add_child(npc_node)
    #This needs to be handled differently once we save/load as NPCs change quests/move around, but for now..
    for npcdef:CityNPCDef in city_def.default_npcs:
        print("BLARP!")
        var npc := CityNPC.new()
        npc_node.add_child(npc)
        print("NPC?", npc)
        npc.unpack(npcdef)
        npcs.append(npc)

        npc.name = npcdef.display_name

        


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
