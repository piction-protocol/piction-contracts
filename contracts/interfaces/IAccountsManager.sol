pragma solidity ^0.4.24;

contract IAccountsManager {    
    function availableId(string id) public view returns(bool isAvailable);
    function availableUserHash(string userHash) public view returns(bool isAvailable);
    function getUserAddress(string userHash) public view returns(address publicKey);
    function accountValidation(string userHash, string rawData) external view returns(bool isValid);
}