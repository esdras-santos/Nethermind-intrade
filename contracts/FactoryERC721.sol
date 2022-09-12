pragma solidity ^0.8.9;

import "./ERC721Collection.sol";

contract FactoryERC721{
    address private owner;
    mapping (string=>address[]) private _collectionByYear;    

    constructor(address _owner){
        owner = _owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function dropCollection(
        address[] memory _interns,
        string memory _year, 
        string memory _tokenURI,
        string memory _collectionName,
        string memory _collectionSymbol
    ) external onlyOwner {
        require(_collectionByYear[_year].length < 13, "can't mint more collection than 13");
        ERC721Collection collection = new ERC721Collection(_collectionName, _collectionSymbol);
        for(uint i; i < _interns.length; i++){
            require(_interns[i] != address(0));
            collection.createCollectible(_interns[i], _tokenURI);
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