extends RefCounted #Node?
class_name BlackBoard

var blackboard = {}

func bbset(key, value, blackboard_name = 'default'):
  if not blackboard.has(blackboard_name):
    blackboard[blackboard_name] = {}

  blackboard[blackboard_name][key] = value


func bbget(key, default_value = null, blackboard_name = 'default'):
  if bbhas(key, blackboard_name):
    return blackboard[blackboard_name].get(key, default_value)
  return default_value


func bbhas(key, blackboard_name = 'default'):
  return blackboard.has(blackboard_name) and blackboard[blackboard_name].has(key) and blackboard[blackboard_name][key] != null


func bberase(key, blackboard_name = 'default'):
  if blackboard.has(blackboard_name):
     blackboard[blackboard_name][key] = null
