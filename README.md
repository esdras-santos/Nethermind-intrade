# Nethermind internal trader

## Motivation

The Idea behind that project is that you can create a group who trade assets internally and to do that a `SBT` (soulbounded token) is used to link the asset to a “soul” in our case the assets are `Nethermind` NFTs, this have the power to  create a feeling of belonging and narrow the relationship between the interns because if they want to trade they will need to talk to each other, this can be used not only by `Nethermind` but for any one that wanna create an internal trade market of assets or just wanna give trade allowance to someone that belongs to an specific group. 

How will the SBTs work? The `SBT` will work like a digital identification inside `Nethermind`; this identification can be issued and revoked by `Nethermind`(operations and HR team). The ID number is derived from the `uint256` of the `keccak256` of the intern name and the account address of the intern will be linked to his SBT and can be changed by the operations and HR team.

### Use case examples:

`Group in a game`: if you have a grup in a game that use NFTs to tokenize their assets, but you want just the players that belong to a specific group to trade between each other in an internal market of game assets and even if some player looses his account address he still can recover their tokens with his SBT id. 

`Prevent under age`: you have a market place and you want prevent under age people to buy your assets, you can just issue SBT ids to people that are above legal age and just this guys will be able to trade in your internal market.

### SBT contract:

The SBT will work just like a passport that will give access to the `Nethermind` internal trade platform in this trade platform only `Nethermind` employers are able to trade. bellow is explained how the SBT contract make that. The contract is made to deal with `ERC721` and `ERC1155`, but is recomended to chose just one of them in future updates.

`issue` function: with this function `Nethermind` (operations and HR team) can issue a SBT to an intern. This function will receive the "name" of the intern, "account" address and "url" with the intern metadata that can be his personal informations.

`revoke` function: with this function `Nethermind` (operations and HR team) can revoke the SBT from an intern and when the SBT is revoked the tokens (`ERC721` and/or `ERC1155`) that are associated with his id are all revoked as well because the tokens are not just linked to an account address but as well aas the SBT id of the intern.

`changeAccount` function: with this function `Nethermind` (operations and HR team) can change the current account of an intern and since the NFTs and dynamic NFTs are associated with the SBT id all the tokens of the old account will be transfered to the new account. This is useful in case the intern lose access to his old account.

`tokenURL` function: return the URL that points the metadata of an intern token and this metadate can contain all the personal informations of an intern.

`accountById` function: return the current account associated the intern id.

`idByAccount` function: return the id that is linked to the account.


### ERC721 contract:

The functions `getApproved`, `setApprovalForAll`, `transferFrom` and  `safeTransferFrom` are modified to receive the id (issued by the SBT contract) of the interns instead of his accounts addresses, this happens because the tokens are linked to the ids and only who have an SBT id of `Nthermind` are allowed to trade inside this internal trade market.


### ERC1155 contract: 

The functions `setApprovalForAll`, `safeBatchTransferFrom` and  `safeTransferFrom` are modified to receive the id (issued by the SBT contract) of the interns instead of his accounts addresses, this happens because the tokens are linked to the ids and only who have an SBT id of `Nthermind` are allowed to trade inside this internal trade market.
