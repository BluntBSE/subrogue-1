extends Node3D
class_name Faction
var faction_layer:int
@export var display_name:String

@export var faction_color:Color #We kind of always want players to be the same color to themselves.
#Is this a simple matter of not synchronizing the property in multiplayer? 00aea8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #Register self with global faction list
    set_faction_ids()
    #For now, let's set faction names by naming the nodes in the editor.
    #That shit gonna need formatting tho
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    


func spawn_entity_at_node(node:NavNode, type_id:String, for_faction:Faction):
    if get_multiplayer_authority() == 1:
        var entity:Entity = preload("res://engine/entities/generic_entity.tscn").instantiate()
        #TODO: update this to the appropriate faction entity controller
        var entity_controller:EntityController = get_node("FactionEntities")
        var is_npc:bool = GlobalConst.is_layer_player(for_faction.faction_layer)
        entity_controller.add_child(entity)
        entity.behavior.destination_node = get_tree().root.find_child("NavNode_Gibraltar", true, false)
        entity.position = node.position
        entity.unpack(type_id, for_faction, null)


func set_faction_ids():
    print(self.name, "Shouldn't be a player here")
    var faction_parent = get_parent() #Thise node is expected to hold all the factions beneath it
    for i in range(faction_parent.get_children().size()):
        if faction_parent.get_children()[i] == self:
            var my_num:int = i + 1 #Factions are 1-indexed.
            var layer_key_string = "FACTION_"+str(my_num)
            faction_layer = GlobalConst.layers[layer_key_string]
            #Register with global faction list
            var faction_key_string = "faction_"+str(my_num)
            var game_root:GameRoot = get_tree().root.find_child("GameRoot", true, false)
            game_root.factions[faction_key_string] = self

    
    pass
