extends ActionLeaf

var flee_time = 1.0 #Always flee for at least one second. Let's make this game time.
func tick(actor:Entity, blackboard:BlackBoard):
    var last_fled_time = blackboard.bbget("last_fled_time")
    if last_fled_time == null:
        return FAILURE 
    var elapsed_time = Time.get_ticks_msec() - last_fled_time
    if (elapsed_time / 1000.0 ) >= flee_time: 
        blackboard.bbset("recently_fled", false)
        blackboard.bbset("needs_reset", true)
    return SUCCESS
