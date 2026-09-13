class_name PlayerManager
extends RefCounted

var player_one: Dictionary = {}
var player_two: Dictionary = {}

func set_players(left_player: Dictionary, right_player: Dictionary) -> void:
	player_one = left_player.duplicate(true)
	player_two = right_player.duplicate(true)

func get_player(player_id: String) -> Dictionary:
	if player_one.get("id", "") == player_id:
		return player_one.duplicate(true)
	if player_two.get("id", "") == player_id:
		return player_two.duplicate(true)
	return {}

func ids() -> Array:
	return [player_one.get("id", ""), player_two.get("id", "")]
