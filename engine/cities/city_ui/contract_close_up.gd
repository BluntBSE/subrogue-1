extends Control
class_name ContractCloseUp


@onready var contract_npc_label = %ContractNPCLabel
@onready var mission_details_label = %MissionDetailsLabel
@onready var mission_details_sub_label = %MissionDetailsLabel
@onready var mission_goals = %MissionGoals
var active_quest:Quest

func unpack(quest:Quest):
    print("Got to contract closeup unpack")
    active_quest = quest
    render_mission(active_quest)


func render_mission(quest:Quest):
    for child in mission_goals.get_children():
        child.queue_free()

    if quest is MurderTypeQuest:
            print("Received a muder type quest")
            quest as MurderTypeQuest
            for condition in quest.conditions:
                print("Condition is: ", condition)
                if condition is MurderTypeQuest.HuntCondition:
                    print("It's a hunt condition!")
                    var faction_string = condition.target_faction.display_name
                    var destroy_num = condition.required_count
                    #Good gravy how you gonna localize that?
                    var str = "Destroy " + str(destroy_num) + " commercial vessels belonging to " + faction_string
                    var rtl := RichTextLabel.new()
                    rtl.fit_content = true
                    rtl.text = str
                    rtl.theme = preload("res://engine/player_ui/player_ui_theme.tres")
                    %MissionGoals.add_child(rtl)

   

func render_conditions(quest:Quest):
    pass
