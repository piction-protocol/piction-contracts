pragma solidity ^0.4.24;

contract IUpdateAddress {
    function updateAddress() external;

    event UpdateAddress(address beforeAddr, address afterAddr);
}