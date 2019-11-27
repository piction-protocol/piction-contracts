pragma solidity ^0.4.24;

interface IValidation {

    function stringValidation(string str) external view returns(bool);

    function accountValidation(address user) external view returns (bool);
}