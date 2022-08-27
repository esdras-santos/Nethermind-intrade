pragma solidity ^0.8.9;

import "./NethermindSBT.sol";
import "./ModifiedERC721.sol";

contract InternNFT is ModifiedERC721{
    address private hr;
    address private operations;
    uint256 private tokenCounter;
    mapping (uint256=>string) private tokenUri;

    struct MultSig{
        bool opVoted;
        bool hrVoted;
        uint8 votes;
    }

    MultSig private signatures;

    modifier onlyNethermind(){
        require(msg.sender == operations || msg.sender == hr, "you're not allowed to use that function");
        if(signatures.votes < 1){
            if(msg.sender == operations){
                require(signatures.opVoted == false,"Operations already sign");
                signatures.votes += 1;
                signatures.opVoted = true;
            } else if(msg.sender == hr){
                require(signatures.hrVoted == false,"HR already sign");
                signatures.votes += 1;
                signatures.hrVoted = true;
            }
        } else if(signatures.votes < 2) {
            if(msg.sender == operations){
                require(signatures.opVoted == false,"Operations already sign");
                signatures.hrVoted = false;
            } else if(msg.sender == hr){
                require(signatures.hrVoted == false,"HR already sign");
                signatures.opVoted = false;
            }
            signatures.votes = 0;  
            _;
        } 
    }

    constructor(address _hr, address _operations, address _sbt) ModifiedERC721("InternsNFT","INFT", _sbt) {
        hr = _hr;
        operations = _operations;
        tokenCounter = 0;
    }

    function issueCollectible(uint256 _internId, string memory _tokenURI) external onlyNethermind returns(uint256) {
        uint256 newItemId = tokenCounter;
        address _internAddress = getInternAddress(_internId);
        _safeMint(_internAddress, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        tokenCounter = tokenCounter + 1;
        return newItemId;
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) private{
        tokenUri[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        return tokenUri[tokenId];
    }

}