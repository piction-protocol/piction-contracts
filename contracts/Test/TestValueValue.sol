pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";

contract TestValidValue is ValidValue {
    function testValidRange(uint256 value) public pure validRange(value) returns(bool result) {
        result = true;
    }

    function testValidAddress(address value) public view validAddress(value) returns(bool result) {
        result = true;
    }

    function testValidString(string value) public pure validString(value) returns(bool result) {
        result = true;
    }

    function testValidRate(uint256 value) public pure validRate(value) returns(bool result) {
        result = true;
    }
}