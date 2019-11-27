pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "../utils/ExtendsOwnable.sol";


contract AccountManager is ExtendsOwnable, ValidValue {

    struct account {
        bool isRegistered;
        string loginId;
        string email;
    }

    mapping (address => account) accounts;
    mapping (string => bool) isDuplicateString;

    function signup(string loginId, string email) external validString(loginId)  validString(email) {
        require(!accounts[msg.sender].isRegistered, "AccountManager signup 0");
        require(!isDuplicateString[loginId], "AccountManager signup 1");
        require(!isDuplicateString[email], "AccountManager signup 2");
        
        accounts[msg.sender].isRegistered = true;
        accounts[msg.sender].loginId = loginId;
        accounts[msg.sender].email = email;

        isDuplicateString[loginId] = true;
        isDuplicateString[email] = true;

        emit Signup(msg.sender, loginId, email);
    }

    function migration(address user, string loginId, string email) external onlyOwner validString(loginId) validString(email) {
        require(!accounts[user].isRegistered, "AccountManager migration 0");
        require(!isDuplicateString[loginId], "AccountManager migration 1");
        require(!isDuplicateString[email], "AccountManager migration 2");

        accounts[user].isRegistered = true;
        accounts[user].loginId = loginId;
        accounts[user].email = email;

        isDuplicateString[loginId] = true;
        isDuplicateString[email] = true;

        emit Migration(msg.sender, user, loginId, email);
    }

    function accountValidation(address user) external view returns (bool) {
        return accounts[user].isRegistered;
    }

    function stringValidation(string str) external view returns (bool) {
        return isDuplicateString[str];
    }

    function getAccount(address user) external view returns (bool, string, string) {
        return (accounts[user].isRegistered, accounts[user].loginId, accounts[user].email);
    }

    event Signup(address indexed sender, string loginId, string email);
    event Migration(address indexed sender, address indexed user, string loginId, string email);
}