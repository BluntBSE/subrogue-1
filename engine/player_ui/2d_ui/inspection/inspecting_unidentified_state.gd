extends GenericState
class_name InspectingUnidentifiedState
var _ref:InspectionRoot

func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
func stateEnter(_args: Dictionary) -> void:
    _ref = _reference
    var sig:SignalPopup = _args.signal
    _ref.signal_inspector_panel.visible = true
    _ref.signal_player.play("slide_in")
    #The second you open, recalculate stuff like size, etc. Forces an update.
    sig.stream.emit({"volume":sig.sound.volume, "pitch":sig.sound.pitch, "certainty":sig.certainty, "entity": sig.detected_object})

    pass
func stateExit() -> void:
    _ref.signal_inspector_panel.visible = false
    pass
