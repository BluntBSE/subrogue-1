extends Node3D
class_name SonarControl3D

@export var angle_1 = 340.0
@export var angle_2 = 20.0
@export var a_diff: float
@export var hover_texture:Texture2D
@export var regular_texture:Texture2D
@onready var mesh_1:MeshInstance3D = %ControlMesh1
@onready var mesh_2:MeshInstance3D = %ControlMesh2
var base_transparency = 0.8
var hovered_transparency = 0.0
var knob_1_active: bool = false
var knob_2_active: bool = false

signal s_angle_1
signal s_angle_2
signal ping_requested  #Emits with angleA, angleB


func _ready():
    mesh_1.material_override = mesh_1.material_override.duplicate()
    mesh_1.transparency = base_transparency
    mesh_2.material_override = mesh_2.material_override.duplicate()
    mesh_2.transparency = base_transparency

func _on_controlmesh1_mouse_entered() -> void:
    print("Entered")
    knob_1_active = true
    mesh_1.material_override.albedo_texture = hover_texture
    mesh_1.transparency = hovered_transparency #Note that this is not the material override .transparency property, which sets whether transparency is even legal at all
    SoundManager.play_straight("button_hovered", "ui")
    pass # Replace with function body.


func _on_controlmesh1_mouse_exited() -> void:
    knob_1_active = false
    mesh_1.material_override.albedo_texture = regular_texture
    mesh_1.transparency = base_transparency
    pass # Replace with function body.


func _on_controlmesh2_mouse_entered() -> void:
    mesh_2.material_override.albedo_texture = hover_texture
    mesh_2.transparency = hovered_transparency
    knob_2_active = true
    SoundManager.play_straight("button_hovered", "ui")

    pass # Replace with function body.


func _on_controlmesh2_mouse_exited() -> void:
    #Careful about input triggering a mouse exit.
    knob_2_active = false
    mesh_2.material_override.albedo_texture = regular_texture
    mesh_2.transparency = base_transparency
    pass # Replace with function body.
