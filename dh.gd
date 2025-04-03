class_name dh

# Called when the node enters the scene tree for the first time.
static func dprint(flag:bool, ref:Node, string:String,):
    if flag == true:
        var whole_str = "Printing from  " + ref.name + " " + string
        print(whole_str)
