class_name BetProvider
extends RefCounted

## Handles stake validation and locking. A future implementation may use an
## escrow contract or a custodial ledger, but the match code sees this API only.

func can_lock(_player_id: String, _stake: int) -> bool:
	push_error("BetProvider.can_lock must be implemented by a concrete provider.")
	return false

func lock_stake(_match_id: String, _player_id: String, _stake: int) -> bool:
	push_error("BetProvider.lock_stake must be implemented by a concrete provider.")
	return false

func get_prize_pool(_match_id: String) -> int:
	push_error("BetProvider.get_prize_pool must be implemented by a concrete provider.")
	return 0
