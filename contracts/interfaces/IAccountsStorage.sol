pragma solidity ^0.4.24;

contract IAccountsStorage {
    function setAddressRegistration(address sender, string hash) public;
    function getAddressRegistration(address sender) public view returns(string hash);
}