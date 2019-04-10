pragma solidity ^0.4.24;

interface IAccountsStorage {
    function setBooleanField(string key, bool value) external;
    function setStringField(string key, string value) external;
    function setUintField(string key, uint256 value) external;
    function setAddressField(string key, address value) external;
    function getBooleanField(string key) external view returns(bool value);
    function getStringField(string key) external view returns(string value);
    function getUintField(string key) external view returns(uint256 value);
    function getAddressField(string key) external view returns(address value);
}