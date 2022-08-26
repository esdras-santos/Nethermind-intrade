# Nethermind internal trader

## Motivation

The Idea behind that project is that you can create a group who trade assets internally and to do that a `SBT` (soulbounded token) is used to link the asset to a “soul” in our case the assets are `Nethermind` NFTs, this have the power to  create a feeling of belonging and narrow the relationship between the interns because if they want to trade they will need to talk to each other, this can be used not only by `Nethermind` but for any one that wanna create an internal trade of assets or just wanna give trade allowance to someone that belongs to an specific group. 
How will the SBTs work? The `SBT` will work like a digital identification inside `Nethermind`; this identification can be issued and revoked by `Nethermind`(operations and HR team). The ID number is derived from the `uint256` of the `keccak256` of the intern name and the account address of the intern will be linked to his SBT and can be changed by the operations and HR team.
The NFTs contracts: they will check if `from` and `to`  have an SBT of `Nethermind` and only after that they will transfer the assets.
