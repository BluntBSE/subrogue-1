extends Node3D
class_name SonarControl3D

@export var angle_1 = 340.0
@export var angle_2 = 20.0
@export var a_diff: float
@export var hover_texture:Texture2D
@export var regular_texture:Texture2D
@onready var mesh_1:MeshInstance3D = %ControlMesh1
@onready var mesh_2:MeshInstance3D = %ControlMesh2
@onready var dir_to_anchor

var camera:Camera3D
var base_transparency = 0.8
var hovered_transparency = 0.0
@onready var knob_pivot_1:Node3D = %KnobPivot1
@onready var knob_pivot_2:Node3D = %KnobPivot2
var knob_1_dragged: bool = false
var knob_2_dragged: bool = false
var knob_1_hovered:bool = false
var knob_2_hovered:bool = false
var knob_1_last_dist
var knob_2_last_dist
var dragging:bool = false

signal s_angle_1
signal s_angle_2
signal ping_requested  #Emits with angleA, angleB


func unpack():
    var current_viewport = get_viewport()
    camera = get_viewport().get_camera_3d()
    #Shift tranform to a bit above the height.
    print("Adjusted global position of the sonar node. May yet be messed up by t")
    
func _ready():
    mesh_1.material_override = mesh_1.material_override.duplicate()
    mesh_1.transparency = base_transparency
    mesh_2.material_override = mesh_2.material_override.duplicate()
    mesh_2.transparency = base_transparency

func _process(_delta:float):
    update_knobs()



func _on_controlmesh1_mouse_entered() -> void:
    print("Entered")
    knob_1_hovered = true
    mesh_1.material_override.albedo_texture = hover_texture
    mesh_1.transparency = hovered_transparency #Note that this is not the material override .transparency property, which sets whether transparency is even legal at all
    SoundManager.play_straight("button_hovered", "ui")
    pass # Replace with function body.


func _on_controlmesh1_mouse_exited() -> void:
    knob_1_hovered = false
    mesh_1.material_override.albedo_texture = regular_texture
    mesh_1.transparency = base_transparency
    pass # Replace with function body.


func _on_controlmesh2_mouse_entered() -> void:
    mesh_2.material_override.albedo_texture = hover_texture
    mesh_2.transparency = hovered_transparency
    print("knob 2 is hovered")
    knob_2_hovered = true
    SoundManager.play_straight("button_hovered", "ui")

    pass # Replace with function body.


func _on_controlmesh2_mouse_exited() -> void:
    #Careful about input triggering a mouse exit.
    knob_2_hovered = false
    mesh_2.material_override.albedo_texture = regular_texture
    mesh_2.transparency = base_transparency
    pass # Replace with function body.


func update_knobs() -> void:
    if knob_1_dragged:
        print("Updaitng knob 1")
        var knob_angle = calculate_knob_angle(mesh_1)
        var dist = calculate_crude_distance(%SonarNode.own_entity.anchor)
        if dist > 0.0:
            knob_1_last_dist = dist
            %ControlMesh1.position.y = abs(dist)
        
        lift_knob_from_surface(%ControlMesh1, %KnobPivot1, %SonarNode.own_entity.anchor)
        if knob_angle != null:
            set_angle_1(knob_angle)
    
    if knob_2_dragged:
        print("Updating knob 2")
        var knob_angle = calculate_knob_angle(mesh_2)
        var dist = calculate_crude_distance(%SonarNode.own_entity.anchor)
        if dist > 0.0:
            knob_2_last_dist = dist
            %ControlMesh2.position.y = abs(dist)
            
        lift_knob_from_surface(%ControlMesh2, %KnobPivot2, %SonarNode.own_entity.anchor)
        if knob_angle != null:
            set_angle_2(knob_angle)
            
func _input(event):
    if event is InputEventMouse:
        event as InputEventMouse
        if event.is_action_pressed("primary_action"):
            if knob_1_hovered == true:
                knob_1_dragged = true
            if knob_2_hovered == true:
                knob_2_dragged = true
                
        if event.is_action_released("primary_action"):
            knob_1_hovered = false
            knob_1_dragged = false
            knob_2_hovered = false
            knob_2_dragged = false
        
    if knob_1_dragged == true or knob_2_dragged == true:
        get_viewport().set_input_as_handled()
       

func lift_knob_from_surface(knob: Node3D, pivot: Node3D, anchor: Planet):
    var max_lift = 1.0  # When maximally far away from the pivot, lift up this much from the anchor's surface.
    var max_dist = 750
    var away_from_planet = (knob.global_position - anchor.global_position).normalized()  # direction
    var dist_from_pivot = (knob.global_position - pivot.global_position).length()
    
    # Calculate interpolation factor (0 to 1) based on distance
    var interpolation_factor = clamp(dist_from_pivot / max_dist, 0.0, 1.0)
    
    # Interpolate lift amount between 0.1 and max_lift
    var lift_amount = 0.1 + (max_lift - 0.1) * interpolation_factor
    
    # Calculate how far the pivot is from the anchor's center
    var pivot_to_anchor_dist = (pivot.global_position - anchor.global_position).length()
    
    # Calculate the new position with the lift applied
    var new_pos = anchor.global_position + away_from_planet * (pivot_to_anchor_dist + lift_amount)
    
    # Set the knob's position
    knob.global_position = new_pos

func calculate_knob_angle(mesh: MeshInstance3D) -> float:
    # Cast a ray from the camera to the mouse position
    var angle
    var mouse_pos = get_viewport().get_mouse_position()
    var from = camera.project_ray_origin(mouse_pos)
    var to = from + camera.project_ray_normal(mouse_pos) * 1000
    
    # Create a plane at the knob's position facing up
    var knob_pos = mesh.global_transform.origin
    #Vector
    var custom_up:Vector3 = (%SonarNode.own_entity.global_position - %SonarNode.own_entity.anchor.global_position).normalized()
    var dist = (%SonarNode.own_entity.global_position - %SonarNode.own_entity.anchor.global_position).length()
    var dir_dist = custom_up * dist
    var plane = Plane(custom_up, dist) #Currently believe this has the sameo rigin as this node. If not, Probably need to extrac tthe component of the knobs
    
    var bd = GlobeHelpers.get_aligned_basis(custom_up)
    


    # Find where the ray intersects the plane
    var intersection = plane.intersects_ray(from, to)
    var local_northsouth = bd.up #I think?
   # GlobeHelpers.visualize_axis(self, local_northsouth, %SonarNode.own_entity.anchor, Color("00ff00"))
    if intersection:
        # Calculate the angle between the intersection point and the center of the sonar
        var center = global_transform.origin
        var to_center = (intersection - center).normalized()
         # Project this vector onto the entity's local coordinate system
        var projected_forward = to_center.dot(bd.up)
        var projected_right = to_center.dot(bd.right)
        
        # Calculate angle in degrees
        angle = rad_to_deg(atan2(-projected_right, projected_forward))
        #angle += 90.0 #Idk man. It just be that way.
        angle = normalize_angle(angle)
        return angle
    
    return angle
    

func calculate_crude_distance(anchor: Planet) -> float:
    dir_to_anchor = (%SonarNode.own_entity.anchor.global_position - position).normalized()

    var mouse_pos = get_viewport().get_mouse_position()
    var from = camera.project_ray_origin(mouse_pos)
    var to = from + camera.project_ray_normal(mouse_pos) * 1000
    
    # Get the physics space state
    var space_state = get_world_3d().direct_space_state
    
    # Set up ray query parameters
    var ray_params = PhysicsRayQueryParameters3D.new()
    ray_params.from = from
    ray_params.to = to
    ray_params.collide_with_areas = true  # Important to detect Area3D nodes
    ray_params.collision_mask  = 1
    # If you want to target only the ClickableSphere, you could set up collision layers
    # ray_params.collision_mask = your_clickable_sphere_layer
    
    # Perform the raycast
    var result = space_state.intersect_ray(ray_params)
    
    # Check if the ray hit something and if it's the ClickableSphere
    if result and "collider" in result:
        var collider = result["collider"]
        
        # Check if the collider is the ClickableSphere or one of its children
        var clickable_sphere = anchor.get_node("ClickableSphere")
        if collider == clickable_sphere or collider.get_parent() == clickable_sphere:
            print("Got a collision at", result["position"])
            # Return the intersection point
            var dist = (result["position"] - position).length()
            return dist
            
    return 0.0
    
    
func calculate_knob_distance():
    # Cast a ray from the camera to the mouse position
    var angle
    var mouse_pos = get_viewport().get_mouse_position()
    var from = camera.project_ray_origin(mouse_pos)
    var to = from + camera.project_ray_normal(mouse_pos) * 1000
    
    # Create a plane at the knob's position facing up
    #Vector
    var custom_up:Vector3 = (%SonarNode.own_entity.global_position - %SonarNode.own_entity.anchor.global_position).normalized()
    var dist = (%SonarNode.own_entity.global_position - %SonarNode.own_entity.anchor.global_position).length()
    var dir_dist = custom_up * dist
    var plane = Plane(custom_up, dist) #Currently believe this has the sameo rigin as this node. If not, Probably need to extrac tthe component of the knobs
    
    var bd = GlobeHelpers.get_aligned_basis(custom_up)


    # Find where the ray intersects the plane
    var intersection = plane.intersects_ray(from, to)
    var local_northsouth = bd.up #I think?
   # GlobeHelpers.visualize_axis(self, local_northsouth, %SonarNode.own_entity.anchor, Color("00ff00"))
    if intersection:
        print(intersection)
        # Center of our little local plane
        var ivector = intersection
        ivector.x = 0.0 #Flatten to local plane
        var center = Vector3(0.0,0.0,0.0) #mid of local plane
        var to_center = (ivector - center).length()
         # Project this vector onto the entity's local coordinate system
        #CLAMP to max dist (currently 750 km)
        print("Dist was perceived to be", to_center)
        return to_center
    print("Could not calculate distance for intersection in calculate knob distance")
    return 0.0
        

func set_angle_1(deg: float) -> void:
    angle_1 = deg
    if angle_1 > 360.0:
        angle_1 -= 360.0
    if angle_1 < 0:
        angle_1 += 360.0
    
    # Update the 3D pivot rotation
    if knob_pivot_1:
        knob_pivot_1.rotation.z = deg_to_rad(angle_1)
    
    s_angle_1.emit(angle_1)

func set_angle_2(deg: float) -> void:
    angle_2 = deg
    if angle_2 > 360.0:
        angle_2 -= 360.0
    if angle_2 < 0:
        angle_2 += 360.0
    
    # Update the 3D pivot rotation
    if knob_pivot_2:
        knob_pivot_2.rotation.z = deg_to_rad(angle_2)
    
    s_angle_2.emit(angle_2)


func normalize_angle(angle: float) -> float:
    # Normalize the angle to the range [0, 360)
    var normalized = fmod(angle, 360.0)
    if normalized < 0:
        normalized += 360.0
    return normalized
