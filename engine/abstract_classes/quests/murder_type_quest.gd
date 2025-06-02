extends Quest
class_name MurderTypeQuest





# Hunt condition: destroy X of category Y for faction Z
class HuntCondition extends QuestCondition:
    var target_faction: Faction
    var category: String
    var required_count: int
    var current_count: int = 0

    func is_satisfied(entity: Entity) -> bool:
        if entity.faction == target_faction and entity.atts.type.category == category:
            current_count += 1
        return current_count >= required_count

# Detection condition: player must not be detected
class DetectionCondition extends QuestCondition:
    var must_not_be_detected: bool

    func is_satisfied(_entity: Entity) -> bool:
        # Implement detection logic here
        #For now return true always
        return true

func enable(player:Player):
    print(name, ": bound entity killed events")
    assigned_to = player
    Events.COMBAT.entity_killed_by.connect(try_complete)
    quest_enabled.emit(self)

# Example: add multiple conditions in quest setup
func build_random_quest_specifics():
    conditions.clear()
    self.display_name = "Overwritten display name from hunt quest"
    # Add hunt condition
    create_hunt_condition()
    # Add detection condition
    var detection = DetectionCondition.new()
    detection.must_not_be_detected = false
    conditions.append(detection)
    # Add more conditions as needed

# When an entity is killed, check all conditions
func try_complete(death_event:Events.Combat.entity_killed_by_object):
    if death_event.killed_by.faction != assigned_to:
        return
    var all_satisfied = true
    for cond in conditions:
        if not cond.is_satisfied(death_event.killed):
            all_satisfied = false
    if all_satisfied:
        complete()

func create_hunt_condition():
    var hunt = HuntCondition.new()
    var valid_factions:Array = exclude_citynpc_faction(for_NPC)
    valid_factions.erase(self.for_faction) #To prevent Saharan Free League from asking you to shoot SFL ships...Unless?
    var target_faction_id = valid_factions.pick_random()
    print("SEEKING TARGET FACTION ID ", target_faction_id)
    var target_faction = get_tree().root.find_child(target_faction_id,true,false)
    print("TARGET FACTION NODE ", target_faction)
    hunt.target_faction = target_faction
    hunt.category = "commercial" #TODO: Make dynamic
    hunt.required_count = 5
    conditions.append(hunt)

func exclude_citynpc_faction(npc:CityNPC):
    var valid_factions = GlobalConst.faction_ids.duplicate()
    valid_factions.erase(npc.faction)
    return valid_factions
