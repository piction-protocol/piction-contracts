pragma solidity ^0.4.24;

contract IAccountsManager {
    function createAccount(string id, string hash, string json) external;
    function accountValidation(string id, string hash, string json) public view returns (bool isValid);
    function availableId(string id) public view returns(bool isAvailable);
    event CreateAccount(address indexed sender, string id, uint256 timestamp);
}