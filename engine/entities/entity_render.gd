extends Node3D
class_name EntityRender
var default_color:Color
@onready var depth_mesh:MeshInstance3D = %DepthMesh
@onready var sonar_mesh:MeshInstance3D = %SonarPulseMesh
@onready var sonar_mesh_2:MeshInstance3D = %SonarPulseMeshNP
@onready var entity:Entity = get_parent()
var scaling = false
var selected = false
var hovered = false
var observed_by:OrbitalCamera
var released_by_observer = true #This variable tracks whether or not the thing that did the selecting has 'let go' of this selection
#Usually that's the camera.
signal was_selected
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    GlobeHelpers.recursively_update_visibility(self, 1, false)
    sonar_mesh.visible = false
    sonar_mesh_2.visible = false
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    scale_with_camera_distance()
    
    if scaling == true:

            scale_with_fov()
    if selected == true:
            scale_with_fov()


func _unhandled_input(event:InputEvent):
    if selected == true and hovered == false: #AND THIS SIGNAL IS NOT CURRRENTLY WHAT THE PLAYERS LOOKING AT? CHRIST ALMIGHTY
        if event is InputEventMouseButton:
             if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
                deselect()
    
        

func update_private_controls(layer:int, val:bool):
    if entity is not Munition: #Munitions, at this time, do not have sonar controls
        #Sonar controls should only be shown to players, and then only to those who own this entity.
        var updating_for_player:bool = GlobalConst.is_layer_player(layer)
        var own_layer = entity.faction.faction_layer
        if updating_for_player and layer == own_layer:
            sonar_mesh.visible = true
            sonar_mesh_2.visible = true
            %ControlMesh1.visible = true
            %ControlMesh2.visible = true
            %ControlMesh1.set_layer_mask_value(layer, val)
            %ControlMesh2.set_layer_mask_value(layer,val)
            %ControlMesh1second.set_layer_mask_value(layer,val)
            %ControlMesh2second.set_layer_mask_value(layer,val)
        else:
            sonar_mesh.visible = false
            sonar_mesh_2.visible = false
            %ControlMesh1.visible = false
            %ControlMesh2.visible = false      
    

func update_mesh_visibilities(layer:int, val:bool):
    update_private_controls(layer, val)
    depth_mesh.set_layer_mask_value(layer, val)
    sonar_mesh.set_layer_mask_value(layer,val)
    sonar_mesh_2.set_layer_mask_value(layer,val)

    for child in get_children():
        if child.get("layers") != null:
            child.set_layer_mask_value(layer,val)
    


func recursively_modulate_all(node:Node3D, _color:Color):
    #Uniformly sets modulation, albedo, and light color where available.
    for child in get_children():
        if child.get("modulate") != null:
            child.modulate = _color
        
        recursively_modulate_all(child, _color)


func update_depth_sprite(depth:int):
    # GlobalConst.DEPTH  enum DEPTH {swim, crawl, surface}
    if entity is not Munition:
        var swim_sprite:Texture2D = load("res://assets/UI/white_circle_2.png")
        var crawl_sprite:Texture2D = load("res://assets/UI/white_icons/white_square_filled.png")
        var surface_sprite:Texture2D = load("res://assets/UI/white_icons/white_square.png")
        depth_mesh = %DepthMesh
        if depth == 0:
            depth_mesh.material_override.albedo_texture = swim_sprite
        if depth == 1:
            depth_mesh.material_override.albedo_texture = crawl_sprite
        if depth == 2:
            depth_mesh.material_override.albedo_texture = surface_sprite
    if entity is Munition:
        var swim_sprite:Texture2D = load("res://assets/UI/white_circle_2.png")
        var crawl_sprite:Texture2D = load("res://assets/UI/white_icons/white_square_filled.png")
        var surface_sprite:Texture2D = load("res://assets/UI/white_icons/white_triangle.png")
        depth_mesh = %DepthMesh
        if depth == 0:
            depth_mesh.material_override.albedo_texture = swim_sprite
        if depth == 1:
            depth_mesh.material_override.albedo_texture = crawl_sprite
        if depth == 2:
            depth_mesh.material_override.albedo_texture = surface_sprite        

func update_colors(color:Color):
    default_color = color
    %DepthMesh.material_override.albedo_color = color
    %Spotlight.light_color = color
    %HeadingSprite.modulate = color

func _on_entity_mouse_entered() -> void:
    scaling = true
    hovered = true
    #modulate = Color("ffffff")
    %Spotlight.light_color = Color("ffffff")
    %HighlightMesh.visible = true
    pass # Replace with function body.

func _on_entity_mouse_exited() -> void:
    scaling = false
    hovered = false
    #modulate = Color("ffffff")
    %Spotlight.light_color = default_color
    %HighlightMesh.visible = false

    pass # Replace with function body.

func scale_with_camera_distance():
    #Base parameters: at 200 distance, scale of 1.0.
    #At 1000 distance, scale of 3.0
    var camera = get_viewport().get_camera_3d()
    var distance = camera.global_position - global_position
    var ratio = inverse_lerp(30, 300, distance.length())
    var sf = lerp(1.0,3.0, ratio)
    sf = clamp(sf, 0.2,1.5)
    scale = Vector3(sf,sf,sf)

func scale_with_fov():
    # Get the camera and its FOV
    var camera = get_viewport().get_camera_3d()
    if camera == null:
        return

    var fov = deg_to_rad(camera.fov)  # Convert FOV to radians
    var distance = (camera.global_position - global_position).length()

    # Calculate the scale factor to maintain a constant size
    # The apparent size is proportional to the tangent of half the FOV
    var desired_size = 1.0  # The desired size of the entity in world units
    var sf = 2.0 * distance * tan(fov / 2.0) * desired_size

    # Clamp the scale factor to avoid extreme values
    sf = clamp(sf, 0.2, 3.0)
    scale = Vector3(sf, sf, sf)

func select(observer:OrbitalCamera): #Usually OrbitalCamera though
    observed_by = observer
    selected = true
    released_by_observer = false
    observer.release_observed.connect(handle_release_observed)
    was_selected.connect(observer.player.UI.inspection_root.handle_openened_identified_entity)
    observer.player.UI.inspection_root.closed_identified.connect(handle_release_observed)
    was_selected.emit(entity)

func deselect():
    selected = false
    released_by_observer = true
    
func handle_deselection():
    deselect()
    
func handle_release_observed():
    released_by_observer = true
    selected = false
    observed_by.release_observed.disconnect(handle_release_observed)
    was_selected.disconnect(observed_by.player.UI.inspection_root.handle_openened_identified_entity)
    observed_by.player.UI.inspection_root.closed_identified.disconnect(handle_release_observed)
    observed_by = null
