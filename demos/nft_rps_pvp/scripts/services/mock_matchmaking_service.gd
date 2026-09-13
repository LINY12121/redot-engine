class_name MockMatchmakingService
extends MatchmakingService

const VALID_STAKES := [1, 2, 5, 10]

var queues := {
	1: [],
	2: [],
	5: [],
	10: [],
}
var _match_sequence := 0

func join_queue(player: Dictionary, stake: int) -> void:
	if not stake in VALID_STAKES:
		push_error("Unsupported stake: %s" % stake)
		return
	queues[stake].append(player.duplicate(true))
	# The local prototype supplies a simulated player with the same exact stake.
	# A real backend would emit only after pairing two remote queue entries.
	var opponent := _build_simulated_opponent(player)
	_match_sequence += 1
	await Engine.get_main_loop().create_timer(0.9).timeout
	emit_signal("opponent_found", {
		"match_id": "mock-match-%03d" % _match_sequence,
		"stake": stake,
		"player_one": player.duplicate(true),
		"player_two": opponent,
	})
	queues[stake].clear()

func leave_queue(player_id: String, stake: int) -> void:
	if not queues.has(stake):
		return
	queues[stake] = queues[stake].filter(func(entry): return entry.get("id", "") != player_id)

func _build_simulated_opponent(player: Dictionary) -> Dictionary:
	var nft: Dictionary = player.get("nft", {}).duplicate(true)
	var alternate := {
		"token_id": "002",
		"collection_address": "mock:aliens-on-rh",
		"name": "Nebula Rift #002",
		"image": "res://assets/avatars/nebula_rift.png",
		"attributes": [{"trait_type": "Class", "value": "Cipher"}],
		"owner": "mock:player-two",
	}
	if nft.get("token_id", "") == "002":
		alternate = {
			"token_id": "003",
			"collection_address": "mock:aliens-on-rh",
			"name": "Solar Echo #003",
			"image": "res://assets/avatars/solar_echo.png",
			"attributes": [{"trait_type": "Class", "value": "Scout"}],
			"owner": "mock:player-two",
		}
	return {
		"id": "mock:player-two",
		"display_name": "NOVA-02",
		"nft": alternate,
	}
