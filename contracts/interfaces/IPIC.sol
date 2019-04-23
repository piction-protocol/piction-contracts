pragma solidity ^0.4.24;

contract IPIC {
    function totalSupply(string contentsHash) public view returns (uint256);
    function balanceOf(string contentsHash, address owner) public view returns (uint256);
    function transfer(string contentsHash, address from, address to, uint256 value) public returns (bool);
    function burn(string contentsHash, address from, uint256 value) external;
    function mint(string contentsHash) external;
}