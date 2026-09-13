class_name MatchmakingService
extends RefCounted

signal opponent_found(match_data: Dictionary)

## Pairs players only inside the exact same fixed-stake queue.

func join_queue(_player: Dictionary, _stake: int) -> void:
	push_error("MatchmakingService.join_queue must be implemented by a concrete provider.")

func leave_queue(_player_id: String, _stake: int) -> void:
	push_error("MatchmakingService.leave_queue must be implemented by a concrete provider.")
