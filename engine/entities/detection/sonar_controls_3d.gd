extends Node3D
class_name SonarControl3D

@export var angle_1 = 340.0
@export var angle_2 = 20.0
@export var a_diff: float
@export var hover_texture:Texture2D
@export var regular_texture:Texture2D
@onready var mesh_1:MeshInstance3D = %ControlMesh1
@onready var mesh_2:MeshInstance3D = %ControlMesh2
var camera:Camera3D
var base_transparency = 0.8
var hovered_transparency = 0.0
@onready var knob_pivot_1:Node3D = %KnobPivot1
@onready var knob_pivot_2:Node3D = %KnobPivot2
var knob_1_active: bool = false
var knob_2_active: bool = false
var dragging:bool = false

signal s_angle_1
signal s_angle_2
signal ping_requested  #Emits with angleA, angleB


func unpack():
    var current_viewport = get_viewport()
    camera = get_viewport().get_camera_3d()

func _ready():
    mesh_1.material_override = mesh_1.material_override.duplicate()
    mesh_1.transparency = base_transparency
    mesh_2.material_override = mesh_2.material_override.duplicate()
    mesh_2.transparency = base_transparency

func _process(_delta:float):
    update_knobs()

func _on_controlmesh1_mouse_entered() -> void:
    print("Entered")
    knob_1_active = true
    mesh_1.material_override.albedo_texture = hover_texture
    mesh_1.transparency = hovered_transparency #Note that this is not the material override .transparency property, which sets whether transparency is even legal at all
    SoundManager.play_straight("button_hovered", "ui")
    pass # Replace with function body.


func _on_controlmesh1_mouse_exited() -> void:
    knob_1_active = false
    mesh_1.material_override.albedo_texture = regular_texture
    mesh_1.transparency = base_transparency
    pass # Replace with function body.


func _on_controlmesh2_mouse_entered() -> void:
    mesh_2.material_override.albedo_texture = hover_texture
    mesh_2.transparency = hovered_transparency
    knob_2_active = true
    SoundManager.play_straight("button_hovered", "ui")

    pass # Replace with function body.


func _on_controlmesh2_mouse_exited() -> void:
    #Careful about input triggering a mouse exit.
    knob_2_active = false
    mesh_2.material_override.albedo_texture = regular_texture
    mesh_2.transparency = base_transparency
    pass # Replace with function body.


func update_knobs() -> void:
    if knob_1_active:
        var knob_angle = calculate_knob_angle(mesh_1)
        if knob_angle != null:
            set_angle_1(knob_angle)
    
    if knob_2_active:
        var knob_angle = calculate_knob_angle(mesh_2)
        if knob_angle != null:
            set_angle_2(knob_angle)
            

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
    var plane = Plane(custom_up) #Currently believe this has the sameo rigin as this node. If not, Probably need to extrac tthe component of the knobs
    
    var bd = GlobeHelpers.get_aligned_basis(custom_up)
    


    # Find where the ray intersects the plane
    var intersection = plane.intersects_ray(from, to)
    if intersection:
        # Calculate the angle between the intersection point and the center of the sonar
        var center = global_transform.origin
        var direction = (intersection - center).normalized()
        direction.y = 0  # Project onto the xz plane
        
        # Calculate angle in degrees
        angle = rad_to_deg(atan2(direction.x, direction.z))
        angle += 90.0
        if angle < 0:
            angle += 360
        return angle
    
    return angle
    

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
