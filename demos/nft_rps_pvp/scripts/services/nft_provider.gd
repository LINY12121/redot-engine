class_name NFTProvider
extends RefCounted

## Chain-independent NFT metadata interface.
## A future implementation can verify ownership and resolve metadata without
## changing MatchManager or the UI.

func get_owned_nfts(_owner_id: String) -> Array:
	push_error("NFTProvider.get_owned_nfts must be implemented by a concrete provider.")
	return []

func get_nft_by_token_id(_token_id: String) -> Dictionary:
	push_error("NFTProvider.get_nft_by_token_id must be implemented by a concrete provider.")
	return {}
