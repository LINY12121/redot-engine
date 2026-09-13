class_name RoundManager
extends RefCounted

const WINNING_SCORE := 3
const VALID_CHOICES := ["rock", "paper", "scissors"]

var player_one_score := 0
var player_two_score := 0
var resolved_rounds := 0

func reset() -> void:
	player_one_score = 0
	player_two_score = 0
	resolved_rounds = 0

func resolve(player_one_choice: String, player_two_choice: String) -> Dictionary:
	var left := player_one_choice.to_lower()
	var right := player_two_choice.to_lower()
	if not left in VALID_CHOICES or not right in VALID_CHOICES:
		return {"valid": false, "reason": "Invalid choice"}
	var outcome := _compare(left, right)
	if outcome == 1:
		player_one_score += 1
	elif outcome == -1:
		player_two_score += 1
	if outcome != 0:
		resolved_rounds += 1
	return {
		"valid": true,
		"outcome": outcome,
		"player_one_choice": left,
		"player_two_choice": right,
		"player_one_score": player_one_score,
		"player_two_score": player_two_score,
		"round_label": resolved_rounds + 1,
		"is_draw": outcome == 0,
		"match_over": is_match_over(),
		"winner_side": get_winner_side(),
	}

func is_match_over() -> bool:
	return player_one_score >= WINNING_SCORE or player_two_score >= WINNING_SCORE

func get_winner_side() -> int:
	if player_one_score >= WINNING_SCORE:
		return 1
	if player_two_score >= WINNING_SCORE:
		return 2
	return 0

func _compare(left: String, right: String) -> int:
	if left == right:
		return 0
	if (left == "rock" and right == "scissors") or (left == "scissors" and right == "paper") or (left == "paper" and right == "rock"):
		return 1
	return -1
