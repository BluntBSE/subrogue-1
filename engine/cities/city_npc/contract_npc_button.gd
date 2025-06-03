extends Button
class_name ContractNPCButton

func unpack(npc:CityNPC):
    %NPCName.text = npc.display_name
    %NPCJob.text = npc.job
    var faction = get_tree().root.find_child(npc.faction,true,false)
    var faction_display_name:String = faction.display_name
    %NPCFaction.text = faction_display_name
    %NPCPortrait.texture = npc.portrait
    
