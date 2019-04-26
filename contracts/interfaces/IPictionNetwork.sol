pragma solidity ^0.4.24;

interface IPictionNetwork {
    function getAddress(string contractName) external view returns (address pictionAddress);
    function getRate(string contractName) external view returns (uint256 rate);
    function getContentsDistributor(string cdName) external view returns (address cdAddress);

    event SetAddress(address indexed from, string contractName, address pictionAddress);
    event SetRate(address indexed from, string contractName, uint256 rate);
    event SetContentsDistributor(string cdName, address cdAddress);
}