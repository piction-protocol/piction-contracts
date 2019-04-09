pragma solidity ^0.4.24;

interface IPictionNetwork {
    function setAddress(string contractName, address pictionAddress) external;

    function getAddress(string contractName) external view returns (address pictionAddress);

    function setRate(string contractName, uint256 rate) external;

    function getRate(string contractName) external view returns (uint256 rate);

    event SetAddress(
        address indexed from,
        string contractName,
        address pictionAddress,
        uint256 timestamp
    );

    event SetRate(
        address indexed from,
        string contractName,
        uint256 rate,
        uint256 timestamp
    );
}