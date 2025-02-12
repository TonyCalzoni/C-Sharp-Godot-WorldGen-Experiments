class_name WFC_Cell extends Node

var possible_types: Array[String]:
	get:
		return possible_types
	set(value):
		possible_types = value

var is_collapsed: bool:
	get:
		return is_collapsed
	set(value):
		is_collapsed = value

var position: Vector2i:
	get:
		return position
	set(value):
		position = value


func _init(_possible_types: Array[String], _position: Vector2i) -> void:
	possible_types = _possible_types
	position = _position
	is_collapsed = false


func cell_to_string() -> String:
	# return $"Cell at {position}, Collapsed: {IsCollapsed}, Types: {string.Join(", ", PossibleTypes)}";
	
	return "Cell at %v, Collapsed: %s, Types: %s" % [position, is_collapsed, string_array_to_single_string(possible_types)]


func string_array_to_single_string(arr: Array[String]) -> String:
	var ret = ""
	for i in arr:
		if ret != "":
			ret += ", "
		ret += i
	return ret
