extends MeshInstance3D
class_name Planet

@onready var landmat: Material = preload("res://globe_scene/land_backup.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #Frustration!
    if landmat != null:
        mesh.material.next_pass = landmat
    else:
        print("landmat is null in _ready")
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    #Frustration!
    #Only doing this because the resource loader didn't work IDK
    if landmat == null:
        landmat = preload("res://globe_scene/land_backup.tres")
    #print(mesh.material.next_pass.albedo_texture)
    pass
