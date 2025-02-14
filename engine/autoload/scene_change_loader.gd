extends Node
#Script for the Autoload Change Scene Loader

var scene_path
var loading_screen = load("res://loading_screen/loading_screen.tscn")


func change_scene(path):
    scene_path = path
    get_tree().change_scene_to_packed(loading_screen)
