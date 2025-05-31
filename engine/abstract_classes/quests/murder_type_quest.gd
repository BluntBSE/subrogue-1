extends Quest
class_name MurderTypeQuest

var category_to_destroy = "commercial"
var num_to_destroy = 5
var target_parameters #TODO: Later, add...given size, etc.

class MurderQuestParams:
    var faction:Faction
    var category:String
    #Size...
    #Carrying...
    func _init(_faction:Faction, _category:String):
        #Do I need to super?
        category = _category
        faction = _faction
        pass
    


func enable():
    pass

func try_complete(entity:Entity): #Expects to receive dead entities
    if entity.atts.type.category == "commercial":
        num_to_destroy - 1
    
    if num_to_destroy < 1:
        complete()
    pass

func target_matched_parameters(entity:Entity, params:MurderQuestParams) -> bool:
    if params.faction:
        if entity.faction != params.faction:
            return false
            
    if params.category:
        if entity.atts.type.category != params.category:
            return false
    
    return true
