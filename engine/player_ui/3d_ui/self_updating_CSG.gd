extends Node3D
class_name SUCSG
#I'm worried that this is really expensive computationally

@export var csg:CSGPolygon3D
var anchor
var node_a
var node_b
var last_recorded_a:Vector3
var last_recorded_b:Vector3
var needs_updating := true
var threshold:float = 0.3 #If updating fluidly is too expensive, do by threshold

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #RESTORE SUCSG - remove set_process, make CSGPolygon3D visible
    set_process(false)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if needs_updating:
        update_csg(node_a,node_b, anchor)    
    
    #if node_a.position == last_recorded_a:
        #if node_b.position == last_recorded_b:
            #needs_updating = false
            #return
    var diff_a = (last_recorded_a - node_a.position).length()
    var diff_b = (last_recorded_b - node_b.position).length()
    if (node_a.position - last_recorded_a).length() < threshold:
        if (node_b.position - last_recorded_b).length() < threshold:
            needs_updating = false
            return
    needs_updating = true
    


func unpack(_node_a, _node_b, _anchor):
    node_a = _node_a
    node_b = _node_b
    anchor = _anchor

func update_csg(_node_a:Node3D, _node_b:Node3D, anchor:Node3D)->void:
    var path:Path3D
    if csg.get_child(0) == null:
        path = Path3D.new()
        csg.add_child(path)

    else:
        path = csg.get_child(0)
    print("Update CSG was called")

    var curve: Curve3D = Curve3D.new()
    var diff: Vector3 = node_b.position - node_a.position
    var dir = diff.normalized()
    var length = diff.length()
    
    var start_point: Vector3 = Vector3(0.0, 0.0, 0.0) # Path starts at the origin
    var end_point: Vector3 = dir * length
    var mid_point: Vector3 = dir * (length / 2.0)
    
    # Calculate the direction away from the anchor
    var up_dir: Vector3 = (mid_point + node_a.position - anchor.position).normalized()
    
    # Lift the midpoint
    var lift: float = 0.15 * length #TODO: Recalculate based on distance.
    mid_point += up_dir * lift
    
    # Calculate tangents for smooth curve
    var start_tangent: Vector3 = (mid_point - start_point) * 0.5
    var mid_tangent: Vector3 = (end_point - start_point) * 0.25
    var end_tangent: Vector3 = (end_point - mid_point) * 0.5
    
    # Add points to the curve with tangents - In the abstract, if you want the path to sit on the ground, do this.
    #curve.add_point(start_point, Vector3(), start_tangent) # idx 0
    #curve.add_point(mid_point, -mid_tangent, mid_tangent)
    #curve.add_point(end_point, -end_tangent, Vector3())
    
    #If using a CSG, we must offset.
    curve.add_point(start_point-node_a.position, Vector3(), start_tangent) # idx 0
    curve.add_point(mid_point-node_a.position, -mid_tangent, mid_tangent)
    curve.add_point(end_point-node_a.position, -end_tangent, Vector3())
    path.curve = curve
    csg.polygon = [Vector2(0.0,0.0),Vector2(0.0,0.25),Vector2(0.125,0.125)]
    csg.mode = CSGPolygon3D.MODE_PATH
    csg.set_path_node(csg.get_child(0).get_path())

    csg.path_interval = 0.1
    csg.material = load("res://globe_scene/csgmat.tres")
    
    last_recorded_a = _node_a.global_position
    last_recorded_b = _node_b.global_position
    global_position = node_a.global_position
