// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/ISBT.sol";

contract NethermindSBT is ISBT{
    address private issuer;
    uint256 private tokenIdCounter;
    uint256 private _totalSupply;
    string private _name;
    // need to add a list for pending transactions
    mapping (uint256=>string) private uri;
    mapping (uint256=>address) private owner;
    mapping (address=>uint256) private token;

    modifier onlyIssuer(){
        require(msg.sender == issuer);
        _;
    }

    constructor(address _issuer, string memory name_){
        issuer = _issuer;
        _name = name_;
    }
    
    function name() external view returns (string memory){
        return _name;
    }

    function issue(address _soul, string memory _uri) onlyIssuer external {
        require(_soul != address(0));
        uri[tokenIdCounter] = _uri;
        owner[tokenIdCounter] = _soul;
        token[_soul] = tokenIdCounter;
        emit Issued(_soul, tokenIdCounter);
        tokenIdCounter+=1;
        _totalSupply+=1;
    }

    function revoke(address _soul, uint256 _tokenId) onlyIssuer external {       
        delete uri[_tokenId];
        delete owner[_tokenId];
        delete token[_soul];
        _totalSupply-=1;
        emit Revoked(_soul, _tokenId);
    }

    // commutnity recovery to avoid the private key commercialization
    function recover(address _oldSoul, address _newSoul, uint256 _tokenId) external onlyIssuer {
        require(_oldSoul == owner[_tokenId], "current owner is not equal to _oldSoul");
        require(_tokenId == token[_oldSoul], "_oldSoul is not the owner of _tokenId");
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
