pragma solidity ^0.4.24;

interface IPictionNetwork {
    function setManager(string manager, address managerAddr) external;

    function getManager(string manager) external view returns (address managerAddr);

    event SetManager(
        address indexed from,
        string manager,
        address managerAddr,
        uint256 timestamp
    );
}