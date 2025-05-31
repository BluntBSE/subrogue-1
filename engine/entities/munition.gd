extends Entity
class_name Munition

enum GUIDANCE { active, passive, wire, dumb, radar, actipass }
enum DEPTH { swim, crawl, surface }
enum IMPACT_TYPES { munitions, ships, both }
@export var id: String
@export var display_name: String
@export var fired_from: Entity
@export var munition_type: String
@export var guidance_type: int  #accepts GUIDANCE enums
@export var impact_type: int = 2  #Accepts IMPACT_TYPES enums
@export var impact_radius: float
@export var fuel_remaining: float
@export var fuel_max: float
@export var fuel_burn: float
@export var current_depth: int  #accepts DEPTH enums
@export var target_depths: Array  #accepts DEPTH enums
@export var target_pos: Vector3
@export var target_entity: Entity
@export var sprite_override: Texture2D
#PASSIVE SONAR PARAMETERS
@export var tracking_angle: float
@export var tracking_range: float
#@export var activate_after:float #distance to travel before turning on...


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    %EntityDetector.unpack(self)
    unpacked = true
    #TODO: Played_by is just...whatever for now! It should be set by the base class, not this. 
    faction = fired_from.faction
    render.update_mesh_visibilities(faction.faction_layer, true)
    behavior.enable()

    pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var target_interval = 0.0


func _process(delta: float) -> void:
    target_interval += delta
    var mesh_1: MeshInstance3D = %TrackingConeMesh
    var entity: Munition = self
    var up = (entity.anchor.position - entity.position).normalized()
    #This, along wth the funky rotations on the mesh, are how we keep the plane from clipping into the planet.
    mesh_1.look_at(entity.anchor.position)
    mesh_1.rotation.z += deg_to_rad(90.0)
    mesh_1.rotation.z += rotation.z

    if target_interval > 0.25:
        target_interval = 0.0
        target_entity = seek_new_target_passive()
        #Generating a new move command every frame might be excessive. But maybe it's fine?
        #Probably I should put some kind of delta that scales based on how far away we are.
        #Oh well.
        #TODO:
        #Also using the entity's basic move_towards might be more appropriate.
        #You could then use a move command if the signal is LOST.
        if target_entity:
            #I dont actually know why the move_towards approach didnt work.

            var move_command = GlobeHelpers.generate_move_command(self, target_entity.position)
            controller.order_move.emit(move_command)


func seek_new_target_passive():
    var valid_targets: Array = []
    for _entity in detector.local_entities:  #{"entity":entity, "tracked_by":[self, child, child]}
        if _entity == null:
            continue
        #See if the target is within range and can be picked up at all.
        var within = is_within_angle(_entity, 40.0)
        if within:
            var _emission: EntityEmission = _entity.emission
            var _sound = Sound.new(_entity, emission.volume, emission.pitch, emission.profile)
            var _dist = GlobeHelpers.arc_to_km(position, _entity.position, anchor)
            var _final_db = GlobalConst.attenuate_sound(_sound.volume, _sound.pitch, _dist)
            if _final_db > detector.sensitivity:
                valid_targets.append(_entity)

    var closest_target: Entity  #We currently calculate certainty as a function of distance, so "closest" is fine here.
    if valid_targets.size() > 0:
        for target in valid_targets:
            if closest_target == null:
                closest_target = target
            var dist = target.position - position
            if dist < closest_target.position - position:
                closest_target = target

    return closest_target


func on_body_entered_check_for_impact(body):
    #Connected to collision area signal through editor
    #TODO: impact area should be a configurable at some point
    #Don't collide on your own faction
    if body.faction != faction:
        #TODO:
        #Don't collide with other munitions unless you're supposed to (Not yet implemented)
        if impact_type == IMPACT_TYPES.ships:
            if !(body is Munition):
                #Do event here
                damage_target(body)


func damage_target(target: Entity) -> void:
    #TODO: Implement damage. Just kill for now.
    print("DAMAGE TARGET CALLED AGASINT ", target.given_name)
    target.died.emit(target)
    #NOTE: Did you get a weird bug here? Consider what happens if you manage to hit two colliders at once.
    #This shouldn't happen, but I did encounter a bug I had a hard time explaining
    var particles: ParticleNode = %Particles 
    #NOTE: Did you get a weird bug here? Consider what happens if you manage to hit two colliders at once.
    remove_child(particles)
    anchor.add_child(particles)
    particles.global_position = target.global_position
    particles.global_basis = global_basis
    particles.rotation.z += deg_to_rad(180)
    
    particles.explode()
    if played_by:
        played_by.UI.handle_impact_1()
        #TODO: Probably need a like "detonated" signal of some flavor.
    target.queue_free()
    queue_free()

    #TODO: Kill any related signal object on the parent
    pass

#I thought about making this a static function, but we need quite a few things intrinsic to the entity
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
