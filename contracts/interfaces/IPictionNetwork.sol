pragma solidity ^0.4.24;

interface IPictionNetwork {
    function setAddress(string contractName, address pictionAddress) external;
    function getAddress(string contractName) external view returns (address pictionAddress);

    function setRate(string contractName, uint256 rate) external;
    function getRate(string contractName) external view returns (uint256 rate);

    function setContentsDistributor(string cdName, address cdAddress) external;
    function getContentsDistributor(string cdName) external view returns (address cdAddress);

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

    event SetContentsDistributor(
        string cdName,
        address cdAddress
    );
}