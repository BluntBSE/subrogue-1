extends Node 
class_name CityNPC

@export var def:CityNPCDef
@export var portrait:Texture2D
@export var display_name:String
@export var job:String
@export_multiline var vignettes:Array[String]
@export var faction:String #BC Factions are in the tree, we store their name here as a key
@export var quests:Array[Quest]

func unpack(_def:CityNPCDef):
    def = _def
    portrait = def.portrait
    display_name = def.display_name
    job = def.job
    vignettes = def.vignettes
    faction = def.faction
    #TODO: quests 
    #If no quests?
    var quest = generate_quest_for_npc()
    quests.append(quest)

func generate_quest_for_npc()->Quest:
    var quest := MurderTypeQuest.new() #TODO: Make this N of a set
    add_child(quest)
    quest.build_random_quest_basis(self)
    quest.build_random_quest_specifics()
    return quest
