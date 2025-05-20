extends ActionLeaf

var flee_time = 1.0 #Always flee for at least one second
func tick(actor:Entity, blackboard:BlackBoard):
    print("Update fled tick")
    var last_fled_time = blackboard.bbget("last_fled_time")
    if last_fled_time == null:
        return SUCCESS
    var elapsed_time = Time.get_ticks_msec() - last_fled_time
    print("Elapsed was ", elapsed_time)
    if (elapsed_time / 1000.0 ) >= flee_time:
        blackboard.bbset("recently_fled", false)
    return SUCCESS
