pragma solidity ^0.4.24;

interface IPictionNetwork {
    function setAddress(string contractName, address pictionAddress) external;

    function getAddress(string contractName) external view returns (address pictionAddress);

    event SetAddress(
        address indexed from,
        string contractName,
        address pictionAddress,
        uint256 timestamp
    );
}