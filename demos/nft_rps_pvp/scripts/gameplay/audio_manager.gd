class_name AudioManager
extends RefCounted

## Intentionally asset-free in this prototype. Keeping audio calls behind this
## class prevents UI/game code from depending on a future audio implementation.

func play_ui_confirm() -> void:
	pass

func play_countdown_tick() -> void:
	pass

func play_round_result(_outcome: int) -> void:
	pass

func play_match_victory() -> void:
	pass
