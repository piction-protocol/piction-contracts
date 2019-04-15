pragma solidity ^0.4.24;

contract IAccountsManager {
    function createAccount(string id, string userHash, string rawData) external;
    function updateAccount(string id, string userHash, string rawData, address sender) external;
    function deleteAccount(string id, string userHash, string rawData, address sender) external;
    function availableId(string id) public view returns(bool isAvailable);
    function availableUserHash(string userHash) public view returns(bool isAvailable);
    function getUserAddress(string userHash) public view returns(address publicKey);
}