extends RigidBody3D
class_name Entity
@export var is_player:bool = true
var can_dock:bool = false
var can_dock_at:City
var played_by:Player
var controlled_by #NPC Factions?
@export var given_name:String
@onready var controller:EntityController = get_parent()
@onready var anchor:Planet = get_tree().root.find_child("GamePlanet", true, false)
@export var azimuth:float
@export var polar:float
var height:float = GlobalConst.height; #Given that the planet has a known radius of 100. Height of 0.25
@onready var move_tolerance = 0.0
@onready var move_bus:EntityMoveBus = get_node("EntityMoveBus")
@export var speed = GlobeHelpers.kph_to_game_s(240.0) #Debug - hyperfast #TODO: This is fucked now that we dont use physics
@export var max_speed = GlobeHelpers.kph_to_game_s(240.0)
@export var base_color:Color
@export var spot_color:Color
@export var range_color:Color
@onready var spotlight:SpotLight3D = %Spotlight
@onready var range_spot:SpotLight3D = %RangeSpot
@export var scale_factor:float = 1.0
@export var faction:Faction
@export var can_move := true
@onready var atts:EntityAtts = %EntityAttributes
@onready var behavior:EntityBehavior = %EntityBehavior
@onready var emission:EntityEmission = %EntityEmission
@onready var render:EntityRender = %EntityRender
@onready var detector:EntityDetector = %EntityDetector
@export var npc:bool = false
@onready var sonar_node:SonarNode = %SonarNode
@onready var notifications:Notifications = %Notifications
signal can_dock_sig
signal docked
signal died
signal removed #For docking, putting into timeout, etc. Like died, but doesn't trigger death counters etc.
var unpacked := false
var look_tweener:Tween


#OPTIMIZATIONS: set linear velocity only once then don't update it unless the entity has reached a node or must respond
#Maybe height fixes and stuff occur less often if the entity is not visible to a player
#Spawn entity at node occasionally takes a long time for som ereason
#EntityDebugger2D also takes time durnig these stalls
#Rads from position is a bit heavy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    freeze = true
    if Engine.is_editor_hint():
        recursively_update_debug_layers(self, true)
        set_physics_process(false)
        set_process(false)
    else:
        recursively_update_debug_layers(self, false)
    pass # Replace with function body.

func unpack(type_id, _faction:Faction, with_name):
    
    faction = _faction
    is_player = GlobalConst.is_layer_player(_faction.faction_layer)
    if is_player == true: #Eh. This should be a specific value, not a bool, for multiplayer
        played_by = get_parent().get_parent()
        var player_ui:PlayerUIRoot = played_by.UI
        can_dock_sig.connect(player_ui.handle_can_dock) #Disable most hostile actions
        docked.connect(player_ui.handle_docked) #Disable player UI for when city interface is open
        #TODO: Replace with a name chosen by player in advance, or from a list of player sub names
        given_name = NameGenerator.generate_name()
    else:
        #When we create missions, we will want to generate entities with specific names.
        if with_name == null or with_name == "":
            given_name = NameGenerator.generate_name()
            
    if faction.faction_color:
        render.update_colors(faction.faction_color)
        
    render.update_mesh_visibilities(faction.faction_layer, true)   
    #temp spotlight adjustments
    spot_color = Color("d1001a")
    var pos_dict := GlobeHelpers.rads_from_position(position)
    azimuth = pos_dict["azimuth"]
    polar = pos_dict["polar"]

        
    var _type:EntityType = GlobalConst.entity_lib.get(type_id)
    apply_entity_type(_type)
    faction = _faction
    var is_npc:bool = !GlobalConst.is_layer_player(faction.faction_layer)  
    npc = is_npc
    #Turn on AI only for NPCs. We might also want to enable it if this is a munition. Stay tuned.
    if is_npc:
        pass
        #DEBUG: We've temporarily turned their sad brains off because they're expensive
        #behavior.enabled = true
    sonar_node.unpack()
    %EntityDetector.unpack(self)
    unpacked = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if unpacked != true:
        return
    #Because clients sync their own information, only run this stuff if it belongs to you.
    if is_player:
        if controller.player.is_multiplayer_authority():
            fix_height()
            fix_rotation()
            #update_coords()
            move_to_next()
            check_reached_waypoint()
            spotlight.look_at(self.position)
    #If this is an NPC, it's the server's job to move it.
    #Execute only if we're the server
    else:
       # if multiplayer.get_unique_id() == 1 :
            #Will this work on single player? I tried to make this the case, but if experiencing issues, check this
            fix_height()
            fix_rotation()
            #update_coords()
            move_to_next()
            check_reached_waypoint()
            spotlight.look_at(self.position)           
            pass



func update_coords()->void:
    #This function specifically can always go on its own thread I think. 
    #Also tbh do we even...use this at any point? I think we could just get the coordinates whenever
    #We actually want to interrogate them.
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
   # print("Hello from MTN")
    if move_bus.queue.size() < 1:
        return
    if move_bus.queue.size() > 0:
        #print("Queue size has elements on", name)
        var dest:Vector3 = move_bus.queue[0].waypoint

        move_towards(dest)

func move_towards(pos: Vector3) -> void:
    var direction = (pos - position).normalized()
    # Calculate the vector from the center of the sphere to the current position
    var center_to_position = (position - anchor.position).normalized()
    
    # Project the direction vector onto the tangent plane
    var tangential_direction = direction - center_to_position * direction.dot(center_to_position)
    tangential_direction = tangential_direction.normalized()
    
    # Calculate the tangential movement vector with the desired speed
    #var vector = tangential_direction * speed * GlobalConst.time_scale
    var movement = tangential_direction * speed# * GlobalConst.time_scale    
   # print("Speed was ", speed)   
    # Set linear velocity - we're not dealing with acceleration right now.
    #print("movemtn was ", movement)
    position += movement
    #apply_central_force(vector)
    
    # Update the heading sprite to face the right direction
    var heading_sprite: Sprite3D = %HeadingSprite
    heading_sprite.visible = true
    
    # Rotate the whole sprite and heading sprite towards the target
    
    
    if direction != center_to_position:
        if position != anchor.position:
            
            if !is_zero_approx(direction.cross(center_to_position).length()): #I had a reason for this. But I don't remember it anymore.

                var current_facing = position + transform.basis.z
                var target_facing = position - direction
                var local_angle = GlobeHelpers.get_local_angle_between(pos, global_position, center_to_position)
                rotation.z = -deg_to_rad(local_angle)
    
func check_reached_waypoint()->void:
    #Prepare to check for docking
    if behavior.destination_node:
        if move_bus.queue.size() <= 1:
            check_at_destination()
            
    if move_bus.queue.size() > 0:
        var cmd:MoveCommand = move_bus.queue[0]
        var wp:Vector3 = cmd.waypoint
        var direction = (wp - global_position).normalized()
        var movement = direction * speed # * timescale
        var dist = (wp - global_position).length()
        if dist <= movement.length():
            cmd.is_finished()
            %HeadingSprite.visible = false
        
        
func apply_entity_type(type:EntityType):

    if not atts:
        atts = %EntityAttributes
        atts = get_node("EntityAttributes")

    atts.class_display_name = type.display_class
    atts.type = type
    atts.size = type.size
    atts.profile = type.base_profile
    atts.current_hull = type.base_hull
    atts.current_pitch = type.base_pitch
    atts.current_depth = type.depths[0]
    #max_speed = type.base_max_speed
    #TODO: This should probably move once we have different speeds. If we do.
    speed = GlobeHelpers.kph_to_game_s(type.base_max_speed)
    atts.cargo = []
    atts.upgrades = []
    atts.utilities = []
    atts.munitions = []
    atts.depths = type.depths
    atts.debuffs = []

func recursively_update_debug_layers(node, _visible):
    for child in node.get_children():
        if child.get("layers") != null:
            child.set_layer_mask_value(1, _visible)
        recursively_update_debug_layers(child, _visible)
        

func query_any_on_layer(node, layer: int) -> bool:
    for child in node.get_children():
        if child.has_method("get_layer_mask_value"):  # Ensure the child has the method
            if child.get_layer_mask_value(layer):
                return true  # Found a match
        # Recurse into the child
        if query_any_on_layer(child, layer):
            return true
    return false  # No match found
    
#DEBUG INITIATLIZE MOVEMENT
func initial_go_to_destination():
        pass
        #move_bus.order_destination_path()
        
#TODO: This just deletes ships that get to their goal. Eventually they might need more persistent docking or a signal emission relevant to missions.
func check_at_destination():
    
    # Get the world and its direct space state for physics queries
    var space_state = get_world_3d().direct_space_state

    # Create a PhysicsShapeQueryParameters3D for a sphere query
    var query := PhysicsShapeQueryParameters3D.new()
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = 2.0
    query.shape = sphere_shape
    query.transform = Transform3D(Basis(), self.global_position)  # Center the sphere at the node's position
    query.collision_mask = 1 << 18  # Adjust the collision mask if needed to match navnodes (layer 19)
    query.collide_with_areas = true
    # Perform the query
    var results = space_state.intersect_shape(query)

    # Check if any of the results are entities
    for result in results:
        if result.collider == behavior.destination_node:
            died.emit(self) #Obviously this is just for debug purposes, a docked signal would be better so we aren't tracking all docks as deaths
            queue_free()
            return true
    return false


func handle_in_docking_area(city:City):
    if can_dock == false: #This check is necessary because the 3d area you check is a spherical plane.
        #It's nontrivial to check for total "immersion" in the 3D area. This saves you a headache.
        if played_by != null:
            #<Node3D#131969584653>
            #<Node3D#132439346727>
            can_dock = true
            can_dock_at = city
            can_dock_sig.emit(true)

            city.interaction.connect("opened_city", played_by.UI.test_method)
            city.interaction.opened_city.connect(played_by.UI.test_method)       
            city.interaction.opened_city.connect(played_by.UI.handle_opened_city)
            city.interaction.opened_city.emit(city)
            print(city.interaction.get_signal_connection_list("opened_city"))

func handle_leave_docking_area():
    if can_dock == true:
        if played_by != null:
            can_dock = false
            can_dock_sig.emit(false)
            #can_dock_at.interaction.opened_city.disconnect(played_by.UI.handle_opened_city)
            can_dock_at = null

func handle_fully_docked():
    pass
    
func handle_left_docked():
    pass
