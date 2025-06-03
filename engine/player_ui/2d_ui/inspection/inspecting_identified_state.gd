extends GenericState
class_name InspectingIdentifiedState
var _ref:InspectionRoot


func stateEnter(_args: Dictionary) -> void:
    _ref = _reference
    var sig:SignalPopup = _args.signal
    _ref.handle_color_stream(sig.color)
    _ref.entity_inspector_panel.visible = true
    _ref.load_inspected_entity(sig.detected_object)
    _ref.entity_player.play("slide_in")
    SoundManager.play_straight("ui_swoop_1", "ui")   
    
func stateExit() -> void:
    _ref.entity_inspector_panel.visible = false
    pass
func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
