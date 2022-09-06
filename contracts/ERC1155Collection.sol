pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Collection is ERC1155{
    uint256 private tokenCounter;
    address public factory;

    constructor(string memory uri) ERC1155(uri){
        tokenCounter = 0;
    }

    function createCollectible(address _intern) external returns (uint256) {
        uint256 newItemId = tokenCounter;
        _mint(_intern, newItemId, 1, "");
        tokenCounter = tokenCounter + 1;
        factory = msg.sender;
        return newItemId;
    }
}