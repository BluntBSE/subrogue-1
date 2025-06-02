extends Control
class_name ContractCloseUp


@onready var contract_npc_label = %ContractNPCLabel
@onready var mission_details_label = %MissionDetailsLabel
@onready var mission_details_sub_label = %MissionDetailsLabel
@onready var mission_goals = %MissionGoals
var active_quest:Quest

func unpack(quest:Quest):
    active_quest = quest


func render_mission_goals(quest:Quest):
    for child in mission_goals.get_children():
        child.queue_free()
    match quest:
         MurderTypeQuest:
            print("Received a muder type quest")
            quest as MurderTypeQuest
            
            pass
   
