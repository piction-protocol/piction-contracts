pragma solidity ^0.4.24;

interface IStorage {
    function setBooleanValue(string key, bool value, string tag) external;
    function setStringValue(string key, string value, string tag) external;
    function setUintValue(string key, uint256 value, string tag) external;
    function setAddressValue(string key, address value, string tag) external;
    function setBytesValue(string key, bytes value, string tag) external;
    function getBooleanValue(string key) external view returns(bool value);
    function getStringValue(string key) external view returns(string value);
    function getUintValue(string key) external view returns(uint256 value);
    function getAddressValue(string key) external view returns(address value);
    function getBytesValue(string key) external view returns(bytes value);
    event SetBooleanValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetStringValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetUintValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetAddressValue(string indexed tag, string indexed key, uint256 timestamp);
    event SetBytesValue(string indexed tag, string indexed key, uint256 timestamp);
}