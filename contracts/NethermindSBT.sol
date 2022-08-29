// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface DynamicNFT{
    function changeAccount(address _old, address _new)  external;
}

interface NFT{
    function changeAccount(address _old, address _new)  external;
}

contract NethermindSBT {
    uint256 private nethermindId;
    address private operations;
    address private hr;
    // need to add a list for pending transactions
    mapping (address=>uint256) private accountToId;
    mapping (uint256=>string) private url;
    mapping (uint256=>address) private idToAccount;

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

    constructor(address _operations, address _hr, address _nethermindAcc, string memory _nethermindUrl){
        operations = _operations;
        hr = _hr;
        nethermindId = uint256(keccak256(abi.encodePacked("Nethermind")));
        url[nethermindId] = _nethermindUrl;
        idToAccount[nethermindId] = _nethermindAcc;
        accountToId[_nethermindAcc] = nethermindId;
    }
    
    function issue(string memory _name, address _account, string memory _url) onlyNethermind(0x009a0443) external {
        uint256 id = uint256(keccak256(abi.encodePacked(_name)));
        url[id] = _url;
        idToAccount[id] = _account;
        accountToId[_account] = id;
    }

    function revoke(
        uint256 _id, 
        address _dynamicNftCollection, 
        address _nftCollection
    ) onlyNethermind(0x20c5429b) external {
        DynamicNFT dnft = DynamicNFT(_dynamicNftCollection);
        NFT nft = NFT(_nftCollection);
        address account = idToAccount[_id];
        dnft.changeAccount(account, idToAccount[nethermindId]);
        nft.changeAccount(account, idToAccount[nethermindId]);       
        delete url[_id];
        delete accountToId[idToAccount[_id]];
        delete idToAccount[_id];
    }

    function tokenURL(uint256 _id) external view returns(string memory) {
        return url[_id];
    }

    function accountById(uint256 _id) external view returns(address){
        return idToAccount[_id];
    }

    function idByAccount(address _account) external view returns(uint256){
        return accountToId[_account];
    }    

    function changeAccount(
        uint256 _id, 
        address _newAccount,
        address _dynamicNftCollection, 
        address _nftCollection
    ) external onlyNethermind(0x6550f1d2){
        require(_newAccount != address(0x00));
        delete accountToId[idToAccount[_id]];
        idToAccount[_id] = _newAccount;
        accountToId[_newAccount] = _id;
        DynamicNFT dnft = DynamicNFT(_dynamicNftCollection);
        NFT nft = NFT(_nftCollection);
        address account = idToAccount[_id];
        dnft.changeAccount(account, idToAccount[nethermindId]);
        nft.changeAccount(account, idToAccount[nethermindId]);
    }
}
