extends RigidBody3D
class_name Entity
@export var is_player:bool
var played_by:Player
var controlled_by #NPC Factions?
@onready var anchor:Planet = get_tree().root.find_child("GamePlanet", true, false)
@export var azimuth:float
@export var polar:float
@export var height:float = GlobalConst.height; #Given that the planet has a known radius of 100. Height of 0.25
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
@export var faction:int = GlobalConst.layers.PLAYER_1
@export var can_move := true
@onready var atts:EntityAtts = %EntityAttributes
@onready var behavior:EntityBehavior = %EntityBehavior
@onready var emission:EntityEmission = %EntityEmission
@onready var render:EntityRender = %EntityRender
@onready var debug:EntityDebug = %EntityDebug
@export var npc:bool = false
@onready var sonar_node:SonarNode = %SonarNode



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_player == true: #Eh. This should be a specific value, not a bool, for multiplayer
		played_by = get_parent().get_parent()
	#temp spotlight adjustments
	spot_color = Color("d1001a")
	var pos_dict := GlobeHelpers.rads_from_position(position)
	azimuth = pos_dict["azimuth"]
	polar = pos_dict["polar"]
	#DEBUG NPC SETTING bc player unpack isn't a thing yet
	if npc == false:
		print(name, "instantiated as player")
		render.update_mesh_visibilities(GlobalConst.layers.PLAYER_1, true)
   # ("shader_parameter/glow_color") = base_color  
	pass # Replace with function body.

func unpack(type_id, _faction):
	var _type:EntityType = GlobalConst.entity_lib.get(type_id)
	apply_entity_type(_type)
	faction = _faction
	var is_npc:bool = !GlobalConst.is_layer_player(_faction)  
	npc = is_npc
	if npc == true:
		print(name, "instantiated as NPC")
		behavior.enabled = true
		#DEBUG because there's not yet a non player unpack
		render.update_mesh_visibilities(GlobalConst.layers.PLAYER_1, false)

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

	if not atts:
		atts = %EntityAttributes
		atts = get_node("EntityAttributes")
		print("ATTS SHOULD BE", atts)
	print("We skipped the check, and atts is ", atts)
	atts.type = type
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

	
