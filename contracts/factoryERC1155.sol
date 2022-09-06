pragma solidity ^0.8.9;

import "./ERC1155Collection.sol";

contract InternDynamicNFTs{
    address private hr;
    address private operations;
    address private owner;
    mapping (string=>address[]) private _collectionByYear;

    struct MultSig{
        bool opVoted;
        bool hrVoted;
        uint8 votes;
    }

    mapping (bytes4=> MultSig ) private signatures;

    modifier onlyNethermind(bytes4 funcSig){
        if(owner != address(0)){
            require(msg.sender == owner);
            _;
        } else {
            require(msg.sender == operations || msg.sender == hr, "you're not allowed to use that function");
            if(signatures[funcSig].votes < 1){
                if(msg.sender == operations){
                    require(signatures[funcSig].opVoted == false,"Operations already sign");
                    signatures[funcSig].votes += 1;
                    signatures[funcSig].opVoted = true;
                } else if(msg.sender == hr){
                    require(signatures[funcSig].hrVoted == false,"HR already sign");
                    signatures[funcSig].votes += 1;
                    signatures[funcSig].hrVoted = true;
                }
            } else if(signatures[funcSig].votes < 2) {
                if(msg.sender == operations){
                    require(signatures[funcSig].opVoted == false,"Operations already sign");
                    signatures[funcSig].hrVoted = false;
                } else if(msg.sender == hr){
                    require(signatures[funcSig].hrVoted == false,"HR already sign");
                    signatures[funcSig].opVoted = false;
                }
                signatures[funcSig].votes = 0;  
                _;
            }
        }
    }


    constructor(address _operation, address _hr) {
        operations = _operation;
        hr = _hr;
    }

    function dropCollection(
        address[] memory _interns, 
        string memory _uri,
        string memory _year
    ) external onlyNethermind(0x00) {
        require(_collectionByYear[_year].length < 13, "can't mint more collection than 13");
        ERC1155Collection collection = new ERC1155Collection(_uri);
        for(uint i; i < _interns.length; i++){
            require(_interns[i] != address(0));
            collection.createCollectible(_interns[i]);
        }
        _collectionByYear[_year].push(address(collection));
    }

    function collectionByYear(string memory _year) external view returns (address[] memory) {
        return _collectionByYear[_year];
    }

    function setOwner(address _newOwner) external onlyNethermind(0x00) {
        owner = _newOwner;       
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}