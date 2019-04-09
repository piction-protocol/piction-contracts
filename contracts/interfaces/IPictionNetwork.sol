pragma solidity ^0.4.24;

interface IPictionNetwork {
    function setManager(string name, address manager) external;

    function getManager(string name) external view returns (address manager);

    event SetManager(
        address indexed from,
        string name,
        address manager,
        uint256 timestamp
    );
}