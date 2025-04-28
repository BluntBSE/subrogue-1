extends BehaviorTreeNode

class_name Leaf

func _ready():
    if self.get_child_count() != 0:
        pass
        #print("BehaviorTree error: Leaf should not have child ", name)
