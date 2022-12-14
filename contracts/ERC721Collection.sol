pragma solidity ^0.8.0;

// import "./token/ERC721/ERC721.sol";

contract ERC721Collection /*is ERC721 */{
    uint256 private tokenCounter;
    address public factory;
    mapping (uint256=>string) public tokenUri;
    constructor (string memory name, string memory symbol) /* ERC721(name, symbol) */{
        factory = msg.sender;
        tokenCounter = 0;
    }

    function createCollectible(address _intern ,string memory _tokenURI) external returns (uint256) {
        uint256 newItemId = tokenCounter;
        // _safeMint(_intern, newItemId);
        // _setTokenURI(newItemId, _tokenURI);
        tokenCounter = tokenCounter + 1;
        
        return newItemId;
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) private{
        // require(ownerOf(_tokenId) == msg.sender);
        tokenUri[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory){
        return tokenUri[tokenId];
    } 
}