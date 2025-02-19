@tool
extends Area3D
class_name NavNode


@export var neighbors:Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if Engine.is_editor_hint():
        %DebugMesh.transparency = 0.5
    else:
        %DebugMesh.transparency = 1.0
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func add_link(node:NavNode)->void:
    print("Add link called from", name, " to ", node)
    #First, make sure the link doesn't already exist.
    for dict in neighbors:
        if dict.node == node:
            print("Already linked to node,", node.name)
            return
    var new_path = Path3D.new()
    var curve = Curve3D.new()
    curve.add_point(Vector3(0,0,0))
    curve.add_point(node.position - position) #Pretty sure data has to be relative to this node.
    new_path.curve = curve
    add_child(new_path)
    print("PATH IS", new_path)
    if Engine.is_editor_hint():
        print("Switching path owner")
        new_path.owner = get_tree().edited_scene_root
    neighbors.append({"node":node, "path":new_path})

func remove_link(node:NavNode)->void:
    for dict:Dictionary in neighbors:
        if dict.node == node:
            dict.path.queue_free()
            dict.node.queue_free()
            neighbors.erase(dict)
            return


func _on_mouse_entered() -> void:
    if Engine.is_editor_hint():
        %DebugMesh.transparency =  0.0
        var material:Material = %DebugMesh.material_override
        material.albedo_color = Color("#0e98c2")




func _on_mouse_exited() -> void:
    if Engine.is_editor_hint():
        %DebugMesh.transparency = 0.3
        
        var material:Material = %DebugMesh.material_override
        material.albedo_color = Color("#eeee11")
