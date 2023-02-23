module seapad::special_avatar_nft {
    use sui::url::{Self, Url};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const  ERR_ONLY_OWNER: u64 = 401;

    struct SeaPadSpecialAvatarNFT has key, store {
        id: UID,
        url: Url,
    }

    // ===== Events =====

    struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        to: address,
        url: Url,
    }

    // ===== Public view functions =====

    /// Get the NFT's `url`
    public fun url(nft: &SeaPadSpecialAvatarNFT): &Url {
        &nft.url
    }

    // ===== Entrypoints =====

    /// Create a new seapad avatar nft and send to user
    public entry fun mint_to(
        url: vector<u8>,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        //check owner
        assert!(sender == @seapad_special_avatar_nft_owner, ERR_ONLY_OWNER);

        let nft = SeaPadSpecialAvatarNFT {
            id: object::new(ctx),
            url: url::new_unsafe_from_bytes(url)
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            to: recipient,
            url: nft.url,
        });

        transfer::transfer(nft, recipient);
    }

    /// Transfer `nft` to `recipient`
    public entry fun transfer(
        nft: SeaPadSpecialAvatarNFT, recipient: address, _: &mut TxContext
    ) {
        transfer::transfer(nft, recipient)
    }

    /// Permanently delete `nft`
    public entry fun burn(nft: SeaPadSpecialAvatarNFT, _: &mut TxContext) {
        let SeaPadSpecialAvatarNFT { id, url: _ } = nft;
        object::delete(id)
    }
}