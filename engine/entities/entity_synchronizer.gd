extends MultiplayerSynchronizer
class_name EntitySynchronizer

@onready var rcfig:SceneReplicationConfig = SceneReplicationConfig.new()
@onready var entity:Entity = get_parent()
func _ready() -> void:
    # Add the rotation of all children and their recursive sub-children to the replication config
    add_recursive_rotation_properties(get_parent())
    #Add parent position which should be the only position property we care about
    var parent_position = str( get_parent().get_path() ) +":position"
    var parent_rotation = str( get_parent().get_path() ) +":rotation"
    rcfig.add_property(parent_position)
    rcfig.add_property(parent_rotation)
    # Assign the replication config to the MultiplayerSynchronizer
    set_replication_config(rcfig)
    if entity.get_parent() is Player:
        var player:Player = entity.get_parent()
        var player_authority = player.get_multiplayer_authority()
        set_multiplayer_authority(player_authority)

    
func _process(delta: float) -> void:
    # Print all tracked properties during _process
    pass
    
func add_recursive_rotation_properties(node: Node) -> void:
    for child in node.get_children():
        if child is Node3D:
            var prop_str = str(child.get_path()) + ":rotation"
            # Add the rotation property of the child to the replication config
            rcfig.add_property(prop_str)
            print("RCFIG:", rcfig.get_properties())
        # Recursively call the function for sub-children
        add_recursive_rotation_properties(child)
        
