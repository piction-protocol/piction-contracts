pragma solidity ^0.4.24;

contract IStorage {
    function setBooleanValue(string key, bool value, string tag) public;
    function setStringValue(string key, string value, string tag) public;
    function setUintValue(string key, uint256 value, string tag) public;
    function setAddressValue(string key, address value, string tag) public;
    function setBytesValue(string key, bytes value, string tag) public;
    function getBooleanValue(string key) public view returns(bool value);
    function getStringValue(string key) public view returns(string value);
    function getUintValue(string key) public view returns(uint256 value);
    function getAddressValue(string key) public view returns(address value);
    function getBytesValue(string key) public view returns(bytes value);
    event SetBooleanValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetStringValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetUintValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetAddressValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetBytesValue(string indexed tag, string indexed key, uint256 timestamp);
}