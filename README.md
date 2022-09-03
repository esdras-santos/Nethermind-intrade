# Nethermind internal trader


### SBT interface:

`name` function: return the name of the SBT collection.

`issue` function: with this function `Nethermind` (operations and HR team) can issue a SBT to an intern "soul".

`revoke` function: with this function `Nethermind` (operations and HR team) can revoke the SBT from an intern "soul".

`recover` function: with this function `Nethermind` (operations and HR team) can recover a SBT from an old to a new "soul" after aproved by the community recovery process. This function can desincentivize people from buying private keys to get the "souls" bacause no one will buy something that can be recovered by the past owner.

`ownerOf` function: return the owner of the SBT id.

`tokenOfOwner` function: return the SBT id of a "soul".

`totalSupply` function: return the total amount of SBTs in circulation.

`tokenURI` function: return the URI that points to the metadata of an intern SBT.

