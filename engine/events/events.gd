extends Node
var QUESTS = _quests.new()
var COMBAT = _combat.new()


class _quests:
    signal enabled_quest #{"for":player, "quest":quest"}
    signal completed_quest
    signal canceled_quest
    signal failed_quest
    signal unlock #Nothing specific planned yet, but I imagine this is necessary
    signal trigger_event_id #Nothing specific planned yet, but I imagine this is necessary

class _combat:
    signal entity_killed_by
    class entity_killed_by_object:
        var killed:Entity
        var killed_by:Entity
        #TODO: Attribution.
