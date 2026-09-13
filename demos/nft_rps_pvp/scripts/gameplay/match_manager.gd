class_name MatchManager
extends RefCounted

signal phase_changed(phase: String, detail: String)
signal round_resolved(result: Dictionary)
signal match_finished(result: Dictionary)

var bet_provider: BetProvider
var settlement_provider: SettlementProvider
var commit_reveal: CommitRevealService
var round_manager := RoundManager.new()
var player_manager := PlayerManager.new()
var audio_manager := AudioManager.new()

var match_id := ""
var stake := 0
var prize_pool := 0
var active := false
var _demo_opponent_choices: Array[String] = []

func _init(bets: BetProvider, settlement: SettlementProvider, fairness: CommitRevealService) -> void:
	bet_provider = bets
	settlement_provider = settlement
	commit_reveal = fairness

func start_match(match_data: Dictionary) -> bool:
	match_id = match_data.get("match_id", "")
	stake = int(match_data.get("stake", 0))
	player_manager.set_players(match_data.get("player_one", {}), match_data.get("player_two", {}))
	if match_id.is_empty() or stake <= 0:
		return false
	if not bet_provider.lock_stake(match_id, player_manager.player_one.get("id", ""), stake):
		return false
	if not bet_provider.lock_stake(match_id, player_manager.player_two.get("id", ""), stake):
		return false
	prize_pool = bet_provider.get_prize_pool(match_id)
	round_manager.reset()
	active = true
	emit_signal("phase_changed", "ready", "Both virtual stakes locked · $%d prize pool" % prize_pool)
	return true

func play_round(player_one_choice: String) -> Dictionary:
	if not active or not player_one_choice.to_lower() in RoundManager.VALID_CHOICES:
		return {"valid": false, "reason": "Match is not ready"}
	var round_key := "%s-r%d" % [match_id, round_manager.resolved_rounds + 1]
	var player_one_id: String = player_manager.player_one.get("id", "")
	var player_two_id: String = player_manager.player_two.get("id", "")
	var player_two_choice := _choose_opponent_move()
	var player_one_secret := commit_reveal.create_secret()
	var player_two_secret := commit_reveal.create_secret()

	commit_reveal.begin_round(round_key)
	commit_reveal.submit_commitment(round_key, player_one_id, commit_reveal.create_commitment(player_one_choice, player_one_secret))
	emit_signal("phase_changed", "committing", "Your choice is cryptographically locked")
	await Engine.get_main_loop().create_timer(0.55).timeout
	commit_reveal.submit_commitment(round_key, player_two_id, commit_reveal.create_commitment(player_two_choice, player_two_secret))
	if not commit_reveal.both_committed(round_key, player_manager.ids()):
		return {"valid": false, "reason": "Waiting for both commitments"}
	emit_signal("phase_changed", "locked", "Commitments locked · revealing both moves")
	await Engine.get_main_loop().create_timer(0.65).timeout

	var left_ok := commit_reveal.submit_reveal(round_key, player_one_id, player_one_choice, player_one_secret)
	var right_ok := commit_reveal.submit_reveal(round_key, player_two_id, player_two_choice, player_two_secret)
	if not left_ok or not right_ok or not commit_reveal.both_revealed(round_key, player_manager.ids()):
		return {"valid": false, "reason": "Commitment verification failed"}

	var result := round_manager.resolve(
		commit_reveal.get_verified_choice(round_key, player_one_id),
		commit_reveal.get_verified_choice(round_key, player_two_id)
	)
	result["stake"] = stake
	result["prize_pool"] = prize_pool
	result["round_key"] = round_key
	audio_manager.play_round_result(int(result.get("outcome", 0)))
	emit_signal("round_resolved", result)

	if result.get("match_over", false):
		active = false
		var winner_id := player_one_id if int(result.get("winner_side", 0)) == 1 else player_two_id
		settlement_provider.settle(match_id, winner_id, prize_pool)
		result["winner_id"] = winner_id
		result["winner_name"] = player_manager.get_player(winner_id).get("display_name", "Winner")
		emit_signal("match_finished", result)
	return result

func set_demo_opponent_choices(choices: Array[String]) -> void:
	_demo_opponent_choices = choices.duplicate()

func _choose_opponent_move() -> String:
	if not _demo_opponent_choices.is_empty():
		return _demo_opponent_choices.pop_front()
	var choices := RoundManager.VALID_CHOICES
	return choices[randi() % choices.size()]
