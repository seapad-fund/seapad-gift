module seapad::avatar_nft {
    use sui::url::{Self, Url};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const  ERR_ONLY_OWNER: u64 = 401;

    struct SeaPadAvatarNFT has key, store {
        id: UID,
        url: Url,
    }

    // ===== Events =====

    struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        url: Url,
    }

    // ===== Public view functions =====

    /// Get the NFT's `url`
    public fun url(nft: &SeaPadAvatarNFT): &Url {
        &nft.url
    }

    // ===== Entrypoints =====

    /// Create a new seapad avatar nft
    public entry fun mint_to_sender(
        url: vector<u8>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        let nft = SeaPadAvatarNFT {
            id: object::new(ctx),
            url: url::new_unsafe_from_bytes(url)
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            url: nft.url,
        });

        transfer::transfer(nft, sender);
    }

    /// Transfer `nft` to `recipient`
    public entry fun transfer(
        nft: SeaPadAvatarNFT, recipient: address, _: &mut TxContext
    ) {
        transfer::transfer(nft, recipient)
    }

    /// Permanently delete `nft`
    public entry fun burn(nft: SeaPadAvatarNFT, _: &mut TxContext) {
        let SeaPadAvatarNFT { id, url: _ } = nft;
        object::delete(id)
    }
}