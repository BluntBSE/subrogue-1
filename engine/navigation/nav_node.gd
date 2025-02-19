@tool
extends Area3D
class_name NavNode

@export var neighbors:Array[NavNode] = []
@export var neighbor_paths:Array[Path3D] = []
var editor_position
var tolerance = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if Engine.is_editor_hint():
        %DebugMesh.transparency = 0.5
    else:
        %DebugMesh.transparency = 1.0
    pass # Replace with function body.


func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        if editor_position == null:
            editor_position = position
            
        var diff = (position - editor_position).length()
        if diff > tolerance:
            regenerate_paths(true)
            editor_position = position
    pass


func add_link(node:NavNode)->void:
    print("Add link called from", name, " to ", node)
    #First, make sure the link doesn't already exist.
    if node in neighbors:
        print("Existing node connection found")
        return
    var new_path = Path3D.new()
    var curve = Curve3D.new()
    curve.add_point(Vector3(0,0,0))
    curve.add_point(node.position - position) #Pretty sure data has to be relative to this node.
    new_path.curve = curve
    add_child(new_path)
    print("PATH IS", new_path)
    if Engine.is_editor_hint():
        new_path.owner = get_tree().edited_scene_root
    #neighbors.append(node)
    #neighbor_paths.append(new_path)
    #We can't append directly because to interact with the custom setter, we need to use assignment ("=")
    #Editing the resource (the array) directly produces issues described in: https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html
    #Scratch that, apparently we can't assign nodes directly to arrays in the editor, even though I'm positive we've done it at runtime before.
    #It's possible that doing that has actually been shorthand for using NodePath?   
    #Typing my array as [Node3D] or [NavMode] seemed to have worked but what
    #In any case, this works, but be careful editing.
    var new_neighbors = neighbors
    var new_neighbor_paths = neighbor_paths
    node.get_path()
    new_neighbors.append(node)
    new_neighbor_paths.append(new_path)

    neighbors = new_neighbors
    neighbor_paths = new_neighbor_paths
    print("RECIPROCAL")
    node.add_link(self)
func remove_link(node:NavNode)->void:
    pass


func _on_mouse_entered() -> void:
    if Engine.is_editor_hint():
        %DebugMesh.transparency =  0.0
        var material:Material = %DebugMesh.material_override
        material.albedo_color = Color("#0e98c2")

func regenerate_paths(adjacent=false)->void:
    print("Node ", name, " is regenerating its paths")
    for path in neighbor_paths:
        print("Path to regenerate found")
        path.queue_free()
        
    var new_neighbor_paths:Array[Path3D] = []
    
    for neighbor in neighbors:
        var new_path = Path3D.new()
        var curve = Curve3D.new()
        curve.add_point(Vector3(0,0,0))
        curve.add_point(neighbor.position - position) #Pretty sure data has to be relative to this node.
        new_path.curve = curve
        add_child(new_path)      
        if Engine.is_editor_hint():
            new_path.owner = get_tree().edited_scene_root
        new_neighbor_paths.append(new_path)
        if adjacent == true:
            print("Should affect adjacents")
            neighbor.regenerate_paths(false) 
            
    neighbor_paths = new_neighbor_paths 



func _on_mouse_exited() -> void:
    if Engine.is_editor_hint():
        %DebugMesh.transparency = 0.3
        
        var material:Material = %DebugMesh.material_override
        material.albedo_color = Color("#eeee11")
        
func _on_neighbors_set():
    print("Set a neighbor!")
    pass
