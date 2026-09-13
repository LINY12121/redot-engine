class_name WalletService
extends RefCounted

## Chain-independent balance API. The prototype represents credits as integers.

func get_balance(_player_id: String) -> int:
	push_error("WalletService.get_balance must be implemented by a concrete provider.")
	return 0

func credit(_player_id: String, _amount: int) -> void:
	push_error("WalletService.credit must be implemented by a concrete provider.")

func debit(_player_id: String, _amount: int) -> bool:
	push_error("WalletService.debit must be implemented by a concrete provider.")
	return false
