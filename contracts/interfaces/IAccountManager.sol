pragma solidity ^0.4.24;

interface IAccountManager {
    function accountValidation(address user) external view returns (bool);
    function getAccount(address user) external view returns(bool, string);
}