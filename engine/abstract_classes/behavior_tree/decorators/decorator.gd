extends BehaviorTreeNode
class_name Decorator

func _ready():
    if self.get_child_count() != 1:
        print("Behaviortree error: Decorator %s should only have one child" % self.name)
