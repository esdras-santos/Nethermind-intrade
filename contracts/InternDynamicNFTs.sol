pragma solidity ^0.8.9;

import "./ModifiedERC1155.sol";

contract InternDynamicNFTs{
    uint256 private tokenId;
    address private hr;
    address private operations;
    address private sbt;
    mapping (string=>address) private collectionByMonth;
    mapping (address=>string) private monthByCollection;

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

    constructor(address _sbt, address _operation, address _hr) {
        operations = _operation;
        hr = _hr;
        sbt = _sbt;
    }

    function dropCollectibles(address[] memory _interns, string memory _url, string memory month) external onlyNethermind {
        require(sbt != address(0));
        require(collectionByMonth[month] == address(0));
        ModifiedERC1155 dynamicNFT = new ModifiedERC1155(_url, sbt, address(this));
        collectionByMonth[month] = address(dynamicNFT);
        monthByCollection[address(dynamicNFT)] = month;
        for(uint i; i < _interns.length; i++){
            dynamicNFT.mint(_interns[i], tokenId, 1);
        }
        tokenId+=1;
    }

    function getCollection(string memory month) external view returns(address){
        return collectionByMonth[month];
    }

    function getMonth(address collection) external view returns(string memory){
        return monthByCollection[collection];
    }
}