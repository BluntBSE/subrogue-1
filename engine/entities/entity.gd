extends RigidBody3D
class_name Entity
@onready var played_by:Player = get_parent().get_parent()
@onready var anchor:Planet = get_tree().root.find_child("GamePlanet", true, false)
@export var azimuth:float
@export var polar:float
@export var height:float = 100.25; #Given that the planet has a known radius of 100. Height of 5.
@export var move_tolerance = 0.0
@onready var move_bus:EntityMoveBus = get_node("EntityMoveBus")
@export var speed = 20.0
@export var max_speed = 20.0
@export var base_color:Color
@export var spot_color:Color
@export var range_color:Color
@onready var spotlight:SpotLight3D = get_node("MarkerSprite/Spotlight")
@onready var range_spot:SpotLight3D = get_node("MarkerSprite/Spotlight")
@export var scale_factor:float = 1.0

@export var faction:String = "none"
@export var can_move := true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #temp spotlight adjustments
    spot_color = Color("d1001a")
    var pos_dict := GlobeHelpers.rads_from_position(position)
    azimuth = pos_dict["azimuth"]
    polar = pos_dict["polar"]
    var sprite:Sprite3D = get_node("MarkerSprite")
    sprite.material_overlay.set("shader_parameter/glow_color", base_color)
   # ("shader_parameter/glow_color") = base_color
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

    fix_height()
    fix_rotation()
    update_coords()
    move_to_next()
    check_reached_waypoint()
    spotlight.look_at(self.position)



func update_coords()->void:
    var pos_dict := GlobeHelpers.rads_from_position(position)
    azimuth = pos_dict["azimuth"]
    polar = pos_dict["polar"]
    pass

func fix_height()->void:
    #The  entity should always be 5 above the tangential surface of the anchor.
    #If tne anchor has a radius of 100m, the entity shall sit at 100.25, but not otherwise modify its position.
    #A higher height will be more permissive when colliding with the map
    var direction:Vector3 = (position - anchor.position).normalized()
    var desired_position:Vector3 = anchor.position + (direction * height)
    position = desired_position
    pass

func fix_rotation() -> void:
    look_at(anchor.position)

    

func move_to_next()->void:
    if move_bus.queue.size() < 1:
        return
    if move_bus.queue.size() > 0:
        #print("Queue size has elements on", name)
        var dest:Area3D = move_bus.queue[0].waypoint
        print("The start was", position)
        print("Should be moving towards, ", dest.position)
        move_towards(dest.position)

func move_towards(pos: Vector3) -> void:
    print("move towards starting for", name)
    var direction = (pos - position).normalized()
    print("anchor is", anchor)
    
    print("Speed", speed)
    # Calculate the vector from the center of the sphere to the current position
    var center_to_position = (position - anchor.position).normalized()
    
    # Project the direction vector onto the tangent plane
    var tangential_direction = direction - center_to_position * direction.dot(center_to_position)
    tangential_direction = tangential_direction.normalized()
    
    # Calculate the tangential movement vector with the desired speed
    var vector = tangential_direction * speed
    
    print("Vector is ", vector)
    
    # Apply the tangential force
    apply_central_force(vector)
    
func check_reached_waypoint()->void:
    if move_bus.queue.size() < 1:
        return
    var cmd:MoveCommand = move_bus.queue[0]
    var wp:Area3D = cmd.waypoint
    var nav:Area3D = get_node("NavArea")
    var overlaps = nav.get_overlapping_areas()
    if cmd.waypoint in overlaps:
        cmd.is_finished()
    
    
