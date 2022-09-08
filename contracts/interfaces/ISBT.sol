pragma solidity ^0.8.9;

interface ISBT{
    event Issued(address _soul, uint256 _tokenId);

    event Revoked(address _soul, uint256 _tokenId);

    event Recovered(address _oldSoul, address _newSoul, uint256 _tokenId);

    function name() external view returns (string memory);

    function issue(address _soul, string memory _uri) external;

    function revoke(address _soul, uint256 _tokenId) external;

    function recover(address _oldSoul, address _newSoul, uint256 _tokenId) external;

    function ownerOf(uint256 _tokenId) external view returns (address);

    function tokenOfOwner(address _soul) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}