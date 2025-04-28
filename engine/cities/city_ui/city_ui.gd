extends TextureRect
class_name CityUI


func unpack(_city:CityDef, _for_faction:Faction = null):
    %CityNameLabel.text = _city.city_name
    if _for_faction:
        %FactionLabel.text = _for_faction.name
    pass
