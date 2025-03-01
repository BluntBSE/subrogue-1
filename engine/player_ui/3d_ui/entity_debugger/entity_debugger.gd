extends Control
class_name EntityDebugger2D

@onready var debugger:EntityDebug = get_parent().get_parent().get_parent()
@onready var sc = %ScrollContainer
var messages:= []


func add_message(message:String)->void:
    messages.append(message)
    var idx = messages.size()
    var display_str = str(idx) + " - " + message
    var label:RichTextLabel = load("res://engine/player_ui/3d_ui/entity_debugger/debug_label.tscn").instantiate()
    label.text = display_str
    %VBoxContainer.add_child(label)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_message("Entity debugger initialized. Good morning")
    debugger.debug_message.connect(add_message)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    sc.set_deferred("scroll_vertical", sc.get_v_scroll_bar().max_value)
    pass
