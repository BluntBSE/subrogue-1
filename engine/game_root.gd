extends Node3D
class_name GameRoot

#Multiplayer peer ids
var peers = {
    "player_1": null,
    "player_2": null,
    "player_3": null,
    "player_4": null,
    "player_5": null,
    "player_6": null,
}

#Player faction objects
var players = {
    "player_1": null,
    "player_2": null,
    "player_3": null,
    "player_4": null,
    "player_5": null,
    "player_6": null,   
}

#Faction Nodes
var factions = {
    "faction_1": null,
    "faction_2": null,
    "faction_3": null,
    "faction_4": null,
    "faction_5": null,
    "faction_6": null,
    "faction_7": null,
    "faction_8": null,
    "faction_9": null,
    "faction_10": null,
    "faction_11": null,
    "faction_12": null,
}


#This feels like a code smell to me, but I can't think of a sounder way to do this than to track the client level 
