pragma solidity ^0.4.24;

interface IPictionNetwork {
    function setAddress(string contractName, address pictionAddress) external;
    function getAddress(string contractName) external view returns (address pictionAddress);

    function setRate(string contractName, uint256 rate) external;
    function getRate(string contractName) external view returns (uint256 rate);

    function setCDInfo(string cdName, address cdAddress, uint256 rate) external;
    function getCDInfo(address cdAddress) external view returns (string cdName, uint256 rate);

    event SetAddress(
        address indexed from,
        string contractName,
        address pictionAddress
    );

    event SetRate(
        address indexed from,
        string contractName,
        uint256 rate
    );

    event SetCDInfo(
        string cdName,
        address indexed cdAddress,
        uint256 rate
    );
}