pragma solidity ^0.8.9;

import "./ERC1155Collection.sol";

contract FactoryERC1155{
    address private owner;
    mapping (string=>address[]) private _collectionByYear;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }


    constructor(address _owner) {
        owner = _owner;
    }

    function dropCollection(
        address[] memory _interns, 
        string memory _uri,
        string memory _year
    ) external onlyOwner {
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

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;       
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}