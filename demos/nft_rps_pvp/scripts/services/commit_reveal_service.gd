class_name CommitRevealService
extends RefCounted

## Local prototype of a two-party commit/reveal exchange. Choices are never
## exposed until both immutable commitments have been recorded.

var _commitments := {}
var _reveals := {}

func begin_round(round_key: String) -> void:
	_commitments[round_key] = {}
	_reveals[round_key] = {}

func create_secret() -> String:
	return "%s:%s:%s" % [Time.get_ticks_usec(), randi(), randf()]

func create_commitment(choice: String, secret: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update((choice.to_lower() + ":" + secret).to_utf8_buffer())
	return context.finish().hex_encode()

func submit_commitment(round_key: String, player_id: String, commitment: String) -> bool:
	if not _commitments.has(round_key) or _commitments[round_key].has(player_id):
		return false
	_commitments[round_key][player_id] = commitment
	return true

func both_committed(round_key: String, player_ids: Array) -> bool:
	if not _commitments.has(round_key):
		return false
	for player_id in player_ids:
		if not _commitments[round_key].has(player_id):
			return false
	return true

func submit_reveal(round_key: String, player_id: String, choice: String, secret: String) -> bool:
	if not _commitments.has(round_key) or not _commitments[round_key].has(player_id):
		return false
	if not both_committed(round_key, _commitments[round_key].keys()):
		return false
	if _reveals[round_key].has(player_id):
		return false
	var verified: bool = create_commitment(choice, secret) == _commitments[round_key][player_id]
	if verified:
		_reveals[round_key][player_id] = {"choice": choice.to_lower(), "secret": secret}
	return verified

func both_revealed(round_key: String, player_ids: Array) -> bool:
	if not _reveals.has(round_key):
		return false
	for player_id in player_ids:
		if not _reveals[round_key].has(player_id):
			return false
	return true

func get_verified_choice(round_key: String, player_id: String) -> String:
	return _reveals.get(round_key, {}).get(player_id, {}).get("choice", "")
