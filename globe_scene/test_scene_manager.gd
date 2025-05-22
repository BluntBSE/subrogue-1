extends Node3D
class_name TSM #TestSceneManager

#This node just exists to do...Whatever we gotta do to make the trailer and test environment right
#1 - Keeps a fixed number of NPCs circulating in the world
#2 - Provides some special debug buttons to trigger effects on demand

var num_commercial_entities = 40
var num_military_entities = 10
var commercial_entities = []
var military_entities = []

#Random draws will come from this list
var spawn_navnodes = ["NavNode_Miami", "NavNode_NewGibraltar", "NavNode_Reykjavik", "NavNode_Georgetown", "NavNode_Dakhla", "NavNode_Dakar", "NavNode_Cork", "NavNode_StPierre", "NavNode_NewYork"] #No difference between these two right now
var destination_navnodes = []
var commercial_ids = ["debug_commercial"]
var military_ids
var faction_ids = ["SaharanFreeLeague", "Atlantic Empire", "EuropeanFront", "UnitedAmericanRepublics"]

var spawn_check_time = 0.0
var spawn_more = true


func _process(_delta:float)->void:
    spawn_check_time += _delta
    if spawn_check_time >= 2.0:
        if spawn_more == true:
            repopulate_entities()
        spawn_check_time = 0.0
    pass



func repopulate_entities():
    if commercial_entities.size()<num_commercial_entities:
        var entity = new_commercial_entity()
        if entity: #new commercial entity returns nil if it couldnt spawn successfully
            commercial_entities.append(entity)
            entity.died.connect(handle_entity_died)
    pass

func handle_entity_died(entity:Entity):
    print("An erasure occurred")
    commercial_entities.erase(entity)

func _physics_process(_delta:float)->void:
    pass


func new_commercial_entity()->Entity:
    # It might be better to remove the sanity checks from this function and move them a level up. 


    # Select a random appropriate id
    var id_modulo = commercial_ids.size() - 1
    var id_idx
    if id_modulo == 0: 
        id_idx = 0
    else:
        id_idx = randi() % (commercial_ids.size() - 1)
    var id = commercial_ids[id_idx]
    
    # Select a random valid navnode to spawn at
    if spawn_navnodes.size() == 0:
        return
    var spawn_idx
    if spawn_navnodes.size() == 1:
        spawn_idx = 0
    else:
        spawn_idx = randi() % (spawn_navnodes.size() - 1)
    var spawn_id = spawn_navnodes[spawn_idx]
    var spawn_at:NavNode = get_tree().root.find_child(spawn_id, true, false)

    
    # Remove its spawn from the list of valid destinations, that'd be silly.
    var valid_destinations = spawn_navnodes.duplicate()
    valid_destinations.erase(spawn_at)
    
    # Select a random destination. Currently every valid spawn is a valid destination.
    if valid_destinations.size() == 0:
        return
    var dest_idx
    if valid_destinations.size() == 1:
        dest_idx = 0
    else:
        dest_idx = randi() % (valid_destinations.size() - 1)
    var dest = valid_destinations[dest_idx]
    
    # Maps are political. Select a random faction.
    if faction_ids.size() == 0:
        print("No factions available.")
        return
    var f_idx
    if faction_ids.size() == 1:
        f_idx = 0
    else:
        f_idx = randi() % (faction_ids.size() - 1)
    var f_id = faction_ids[f_idx]
    var faction = get_tree().root.find_child("Factions", true, false).get_node(f_id)
    
    if no_entities_near_node(spawn_at, 5.0) == false:
        # If there are entities near where we would spawn, pass this attempt.
        return
    #Consider, refactor this into a call_deferred situation?
    var entity = EntityHelpers.spawn_entity_at_node(spawn_at, id, faction)
    configure_behavior(entity, dest)
    return entity


func no_entities_near_node(node: NavNode, distance: float) -> bool:
    # Get the world and its direct space state for physics queries
    var space_state = get_world_3d().direct_space_state

    # Create a PhysicsShapeQueryParameters3D for a sphere query
    var query = PhysicsShapeQueryParameters3D.new()
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = distance
    query.shape = sphere_shape
    query.transform = Transform3D(Basis(), node.global_position)  # Center the sphere at the node's position
    query.collision_mask = 1  # Adjust the collision mask if needed to match entities

    # Perform the query
    var results = space_state.intersect_shape(query)

    # Check if any of the results are entities
    for result in results:
        if result.collider is Entity:
            return false  # An entity is near the node
    return true  # No entities are near the node


func configure_behavior(entity:Entity, destination_id:String)->void:
    #For now, this only sets a destination for our critter
    var dest:NavNode = entity.get_tree().root.find_child(destination_id, true, false)
    entity.behavior.destination_node = dest
    entity.initial_go_to_destination()
    entity.behavior.enable()
    pass
    
