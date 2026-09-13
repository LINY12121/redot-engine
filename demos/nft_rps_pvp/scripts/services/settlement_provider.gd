class_name SettlementProvider
extends RefCounted

## Finalizes a match after its game result is verified.

func settle(_match_id: String, _winner_id: String, _prize_pool: int) -> bool:
	push_error("SettlementProvider.settle must be implemented by a concrete provider.")
	return false
