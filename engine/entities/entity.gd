@tool
extends RigidBody3D
class_name Entity
@export var is_player:bool = true
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
@export var speed = GlobeHelpers.kph_to_game_s(240.0) #Debug - hyperfast
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
@onready var debug:EntityDebug = %EntityDebug
@onready var detector:EntityDetector = %EntityDetector
@export var npc:bool = false
@onready var sonar_node:SonarNode = %SonarNode
@onready var notifications:Notifications = %Notifications
signal died
var unpacked := false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
        #TODO: Replace with a name chosen by player in advance, or from a list of player sub names
        given_name = NameGenerator.generate_name()
    else:
        #When we create missions, we will want to generate entities with specific names.
        if with_name == null:
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
        behavior.enabled = true
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
            update_coords()
            move_to_next()
            check_reached_waypoint()
            spotlight.look_at(self.position)
    #If this is an NPC, it's the server's job to move it.
    #Execute only if we're the server
    else:
        if multiplayer.get_unique_id() == 1 :
            #Will this work on single player? I tried to make this the case, but if experiencing issues, check this
            fix_height()
            fix_rotation()
            update_coords()
            move_to_next()
            check_reached_waypoint()
            spotlight.look_at(self.position)           
            pass



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

        move_towards(dest.position)

func move_towards(pos: Vector3) -> void:
    
    var direction = (pos - position).normalized()
    # Calculate the vector from the center of the sphere to the current position
    var center_to_position = (position - anchor.position).normalized()
    
    # Project the direction vector onto the tangent plane
    var tangential_direction = direction - center_to_position * direction.dot(center_to_position)
    tangential_direction = tangential_direction.normalized()
    
    # Calculate the tangential movement vector with the desired speed
    var vector = tangential_direction * speed * GlobalConst.time_scale
        
    # Set linear velocity - we're not dealing with acceleration right now.
    linear_velocity = vector
    #apply_central_force(vector)
    
    # Update the heading sprite to face the right direction
    var heading_sprite: Sprite3D = %HeadingSprite
    heading_sprite.visible = true
    
    # Rotate the whole sprite and heading sprite towards the target
    look_at(direction, center_to_position, false)

    #adjust heading sprite rotation to match, assuming Vector3(0,1,0) is the angle to compare to.

    
    
    #heading_sprite.rotation.z = angle
    
func check_reached_waypoint()->void:
    if move_bus.queue.size() < 1:
        return
    var cmd:MoveCommand = move_bus.queue[0]
    var wp:Area3D = cmd.waypoint
    var nav:Area3D = get_node("NavArea")
    var overlaps = nav.get_overlapping_areas()
    if cmd.waypoint in overlaps:
        linear_velocity = Vector3(0.0,0.0,0.0)
        angular_velocity = Vector3(0.0,0.0,0.0)
        cmd.is_finished()
        %HeadingSprite.visible = false
        
        
func apply_entity_type(type:EntityType):
    print(name, "Called apply entity type with", type)

    if not atts:
        atts = %EntityAttributes
        atts = get_node("EntityAttributes")
        print("ATTS SHOULD BE", atts)
    print("We skipped the check, and atts is ", atts)
    atts.class_display_name = type.display_class
    atts.type = type
    atts.size = type.size
    atts.current_hull = type.base_hull
    atts.current_pitch = type.base_pitch
    atts.current_depth = type.depths[0]
    #max_speed = type.base_max_speed
    #TODO: This should probably move once we have different speeds. If we do.
    print("Just set speed to", speed)
    speed = GlobeHelpers.kph_to_game_s(type.base_max_speed)
    atts.cargo = []
    atts.upgrades = []
    atts.utilities = []
    atts.munitions = []
    atts.depths = type.depths
    atts.debuffs = []

func recursively_update_debug_layers(node, _visible):
    for child in node.get_children():
        print("inspecting ", child.name)
        if child.get("layers") != null:
            print("ABOUT TO SET ", child.name, " TO ", _visible)
            child.set_layer_mask_value(1, _visible)
        recursively_update_debug_layers(child, _visible)
    
