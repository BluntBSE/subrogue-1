extends Quest
class_name MurderTypeQuest

var category_to_destroy = "commercial"
var num_to_destroy = 5
var target_parameters:MurderQuestParams #TODO: Later, add...given size, etc.

class MurderQuestParams:
    var faction:Faction
    var category:String
    #Size...
    #Carrying...

    


func enable():
    pass

func try_complete(entity:Entity): #Expects to receive dead entities
    if target_matched_parameters(entity, target_parameters):
        num_to_destroy - 1
    if num_to_destroy < 1:
        complete()


func build_random_quest_specifics():
    #TODO: How are we gonna synchronize these across clients?
    #Overrides parent
    var params := MurderQuestParams.new()
    #exclude quest giver faction as a target option
    var valid_factions:Array = exclude_citynpc_faction(for_NPC)
    var target_faction_id = valid_factions.pick_random()
    var target_faction = get_tree().root.find_child(target_faction_id,true,false)
    
    params.target_faction = target_faction
    
    target_parameters = params
    #Separate above into its own function?
    display_name = "Debug display name for missions!"


func exclude_citynpc_faction(npc:CityNPC):
    var valid_factions = GlobalConst.faction_ids.duplicate()
    valid_factions.erase(npc.faction)
    return valid_factions

func target_matched_parameters(entity:Entity, params:MurderQuestParams) -> bool:
    if params.faction:
        if entity.faction != params.faction:
            return false
            
    if params.category:
        if entity.atts.type.category != params.category:
            return false
    
    return true
