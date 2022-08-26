pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./NethermindSBT.sol";

contract InternNFT is ERC721{
    address private hr;
    address private operations;
    NethermindSBT private sbt;
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

    constructor(address _hr, address _operations, address _sbt) ERC721("InternsNFT","INFT") {
        hr = _hr;
        operations = _operations;
        tokenCounter = 0;
        sbt = NethermindSBT(_sbt);
    }

    function createCollectible(uint256 _internId, string memory _tokenURI) external onlyNethermind returns(uint256) {
        uint256 newItemId = tokenCounter;
        address _internAddress = sbt.accountById(_internId);
        _safeMint(_internAddress, newItemId);
        _setTokenURI(newItemId, tokenURI);
        tokenCounter = tokenCounter + 1;
        return newItemId;
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) private{
        tokenUri[_tokenId] = _tokenURI;
    }

    function safeTransferFrom(uint256 _fromId, uint256 _toId, uint256 _tokenId, bytes memory data) public override payable{
        address _from = sbt.accountById(_fromId);
        address _to = sbt.accountById(_toId);
        super.safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(uint256 _fromId, uint256 _toId, uint256 _tokenId, uint256 _internId) public payable{
        address _from = sbt.accountById(_fromId);
        address _to = sbt.accountById(_toId);
        super.safeTransferFrom(_from, _to, _tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        return tokenUri[tokenId];
    }

    function transferFrom(uint256 _fromId, uint256 _toId, uint256 _tokenId) public payable{
        address _from = sbt.accountById(_fromId);
        address _to = sbt.accountById(_toId);
        super.transferFrom(_from, _to, _tokenId);
    }

    function approve(uint256 _approvedId, uint256 _tokenId) public payable{
        address _approved = sbt.accountById(_approvedId);
        super.approve(_approved, _tokenId);
    }

    function setApprovalForAll(uint256 _operatorId, bool _approved) public{
        address _operator = sbt.accountById(_operatorId);
        super.setApprovalForAll(_operator, _approved);
    }
}