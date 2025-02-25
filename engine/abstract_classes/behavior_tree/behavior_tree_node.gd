@icon("res://engine/abstract_classes/behavior_tree/icons/tree.svg")
extends BehaviorTree

class_name BehaviorTreeNode

enum {SUCCESS, FAILURE, RUNNING}

func tick(actor,blackboard):
    pass
