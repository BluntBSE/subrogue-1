extends Node #I chose Node over Resource because I imagine it will make it easier to inspect the quests of other players in an MP context, plus it seems easy to serialize and gets access to the node tree for comparisons.
class_name Quest
#If you want predfined quests, you can load data from a QuestDef into this node.

enum STATES {available, active, completed, canceled}

#var assigned_to:Player #? Players? Is this even appropriate? I don't think I really want joint missions though since there's ultimately one on top.
var for_faction:Faction
var for_NPC
#var unique_id - Nodes have an RID, right? We might not need unique_ids as a separate variable.
var display_name
var state
var requirements
var channel
var time_limit
var rewards #Faction favor, money, supplies, weapons, MAYBE crew. 
#How do I collapse all that into an array of useful rewards?
#It feels like a lot but honestly I think I will do FavorReward, MoneyReward, SupplyReward, etc. classes
#So that a give_rewards() function can match against the classes in the Array.


func enable():
    pass

func complete():
    
    #Give rewards
    pass

func abandon():
    pass

func retire():
    #Quest wasn't chosen for X time.
    pass

#The proposed flow for assigning a quest to NPCs will be something like...
#When docking, 
#If X time has elapsed since last docked...Or maybe on some fixed interval...
#Determine type of quest
#quest = Quest.new()
#quest.build_random_quest_basis
#Call a function that exists across all specific types of quest (smuggle, murder)
#quest.build_random_quest_specifics

#To avoid an expensive reparenting (even though it's PROBABLY fine...), let's actually spawn these
#Available quests directly on the player and queue_free() them if they're not accepted
#This allows us to keep them in sync in an MP context just by spawning them or not.


func build_random_quest_basis()->void:
    #For faction determinant
    self.for_faction = determine_for_faction() #Probably will accept NPC's faction at some point.
    #self.for_NPC = args.NPC
    #Names actually belong on build_random_quest_specifics 
    self.state = STATES.available #Upon construction, random quests are available. This might eventually change to make them locked if requirements aren't met.
    
func determine_for_faction()->Faction:
    
    var faction_ids = GlobalConst.faction_ids
    if faction_ids.size() == 0:
        print("No factions available.")
        return
    var f_idx
    if faction_ids.size() == 1:
        f_idx = 0
    else:
        f_idx = randi() % (faction_ids.size() - 1)
    var f_id = faction_ids[f_idx]
    var faction = get_tree().root.find_child("Factions", true, false).get_node(f_id)
    
    return faction
