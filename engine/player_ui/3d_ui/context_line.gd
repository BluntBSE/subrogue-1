extends Node3D
var node_a:Node3D
var node_b:Node3D
var anchor:Node3D
var line:Line3D 
var current_curve:Curve3D
var last_recorded_a:Vector3
var last_recorded_b:Vector3
var needs_updating := true
var threshold:float = 0.2 #If updating fluidly is too expensive, do by threshold

func unpack(_node_a, _node_b, _anchor):
    node_a = _node_a
    node_b = _node_b
    anchor = _anchor
    

func update_line3d(_node_a:Node3D, _node_b:Node3D, anchor):
    line.material = load("res://engine/player_ui/context_line.material")
    

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
    
    
    curve.add_point(start_point, Vector3(), start_tangent) # idx 0
    curve.add_point(mid_point, -mid_tangent, mid_tangent)
    curve.add_point(end_point, -end_tangent, Vector3())
    if current_curve != null:
        current_curve = null #Release any old RefCounted curves. 
    current_curve = curve
    line.curve = current_curve #Line automatically updates itself when curve changes, I think.

    
    last_recorded_a = _node_a.global_position
    last_recorded_b = _node_b.global_position
    #global_position = node_a.global_position    
    %Line3D.global_position = node_a.global_position #I don't understand why this is set separately
    pass
    
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    line = %Line3D
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if needs_updating:
        update_line3d(node_a,node_b, anchor)    

    var diff_a = (last_recorded_a - node_a.position).length()
    var diff_b = (last_recorded_b - node_b.position).length()
    if (node_a.position - last_recorded_a).length() < threshold:
        if (node_b.position - last_recorded_b).length() < threshold:
            needs_updating = false
            return
    needs_updating = true
