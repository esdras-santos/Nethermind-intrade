// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/ISBT.sol";

contract NethermindSBT is ISBT{
    address private operations;
    address private hr;
    uint256 private tokenIdCounter;
    uint256 private _totalSupply;
    string private _name;
    // need to add a list for pending transactions
    mapping (uint256=>string) private uri;
    mapping (uint256=>address) private owner;
    mapping (address=>uint256) private token;

    struct MultSig{
        bool opVoted;
        bool hrVoted;
        uint8 votes;
    }

    mapping (bytes4=> MultSig ) private signatures;
    
    // this need to be improved to execute the function like a external call directly from a pending transactions list
    modifier onlyNethermind(bytes4 funcSig){
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

    constructor(address _operations, address _hr, string memory name_){
        operations = _operations;
        hr = _hr;
        _name = name_;
    }
    
    function name() external view returns (string memory){
        return _name;
    }

    function issue(address _soul, string memory _uri) onlyNethermind(0x009a0443) external {
        require(_soul != address(0));
        uri[tokenIdCounter] = _uri;
        owner[tokenIdCounter] = _soul;
        token[_soul] = tokenIdCounter;
        emit Issued(_soul, tokenIdCounter);
        tokenIdCounter+=1;
        _totalSupply+=1;
    }

    function revoke(address _soul, uint256 _tokenId) onlyNethermind(0x20c5429b) external {       
        delete uri[_tokenId];
        delete owner[_tokenId];
        delete token[_soul];
        _totalSupply-=1;
        emit Revoked(_soul, _tokenId);
    }

    // commutnity recovery to avoid the private key commercialization
    function recover(address _oldSoul, address _newSoul, uint256 _tokenId) external onlyNethermind(0x00) {
        require(_oldSoul == owner[_tokenId], "current owner is not equal to _oldSoul");
        require(_newSoul != address(0), "_newSoul is equal to 0");
        owner[_tokenId] = _newSoul;
        delete token[_oldSoul];
        token[_newSoul] = _tokenId;
        emit Recovered(_oldSoul, _newSoul, _tokenId);
    }

    function ownerOf(uint256 _tokenId) external view returns (address){
        return owner[_tokenId];
    }

    function tokenOfOwner(address _soul) external view returns (uint256) {
        return token[_soul];
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;        
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory){
        return uri[_tokenId];
    }
}
