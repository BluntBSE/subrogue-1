extends Entity
class_name Munition

enum GUIDANCE {active, passive, wire, dumb, radar, actipass }
enum DEPTH {swim, crawl, surface}
@export var id:String
@export var display_name:String
@export var fired_from:Entity
@export var munition_type:String
@export var guidance_type: int #accepts GUIDANCE enums
@export var impact_radius:float
@export var fuel_remaining:float
@export var fuel_max:float
@export var fuel_burn:float
@export var current_depth:int #accepts DEPTH enums
@export var target_depths:Array #accepts DEPTH enums
@export var target_pos:Vector3
@export var target_entity:Entity
@export var sprite_override:Texture2D
#PASSIVE SONAR PARAMETERS
@export var tracking_angle:float
@export var tracking_range:float
#@export var activate_after:float #distance to travel before turning on...

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    faction = fired_from.faction
    render.update_mesh_visibilities(faction, true)
    
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float)->void:
    var mesh_1:MeshInstance3D = %TrackingConeMesh
    var entity:Munition = self
    var up = (entity.anchor.position - entity.position).normalized()
    #This, along wth the funky rotations on the mesh, are how we keep the plane from clipping into the planet.
    mesh_1.look_at(entity.anchor.position)
    mesh_1.rotation.z += deg_to_rad(90.0)
    mesh_1.rotation.z += rotation.z
    
    target_entity = seek_new_target_passive()
    #Generating a new move command every frame might be excessive. But maybe it's fine?
    #Probably I should put some kind of delta that scales based on how far away we are.
    #Oh well.
    if target_entity:
        var move_command = GlobeHelpers.generate_move_command(self, target_entity.position)
        controller.order_move.emit(move_command)

func seek_new_target_passive():
    var valid_targets:Array = []
    for _entity in detector.local_entities: #{"entity":entity, "tracked_by":[self, child, child]}
        #See if the target is within range and can be picked up at all.
        var within = is_within_angle(_entity, 40.0)
        if within:
            var emission:EntityEmission = _entity.emission
            var sound = Sound.new(_entity, emission.volume, emission.pitch, emission.profile)
            var dist = GlobeHelpers.arc_to_km(position, _entity.position, anchor)
            var final_db = GlobalConst.attenuate_sound(sound.volume, sound.pitch, dist)
            if final_db > detector.sensitivity:
                valid_targets.append(_entity)
                
    var closest_target:Entity #We currently calculate certainty as a function of distance, so "closest" is fine here.
    if valid_targets.size() > 0:
        for target in valid_targets:
            if closest_target == null:
                closest_target = target
            var dist = target.position - position
            if dist < closest_target.position - position:
                closest_target = target
    
    return closest_target        
            
  
func is_within_angle(target: Node3D, angle: float) -> bool:
    # If the provided angle is 40, this function checks if a target
    # is within the Detection Area and within 20 degrees clockwise and 20 degrees counterclockwise
    # from this node's facing direction.

    # Calculate the "up" vector based on the anchor position
    var up_vector = (self.anchor.position - self.position).normalized()

    # Get the DetectionArea node
    var detection_area: Area3D = %DetectionArea

    # Ensure the target is within the DetectionArea
    if not detection_area.overlaps_body(target):
        return false

    # Calculate the direction vector from this node to the target
    var direction_to_target: Vector3 = (target.global_transform.origin - global_transform.origin).normalized()

    # Get this node's forward direction (assuming +Y is forward)
    var forward_direction: Vector3 = global_transform.basis.y.normalized()

    # Calculate the angle between the forward direction and the direction to the target
    var angle_to_target: float = rad_to_deg(acos(forward_direction.dot(direction_to_target)))

    # Check if the target is within the specified angle range
    return angle_to_target <= angle / 2
