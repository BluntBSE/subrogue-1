extends ActionLeaf

var flee_time = 1.0 #Always flee for at least one second
func tick(actor:Entity, blackboard:BlackBoard):
    print("Hello from update recently")
    var last_fled_time = blackboard.bbget("last_fled_time")
    if last_fled_time == null:
        return FAILURE # Move on down the tree
    var elapsed_time = Time.get_ticks_msec() - last_fled_time
    if (elapsed_time / 1000.0 ) >= flee_time:
        print("FALSO")
        blackboard.bbset("recently_fled", false)
        blackboard.bbset("needs_reset", true)
    return FAILURE #Move on down the tree
