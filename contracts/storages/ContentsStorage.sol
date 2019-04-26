pragma solidity ^0.4.24;

import "./Storage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/ValidValue.sol";
import "../utils/ExtendsOwnable.sol";

contract ContentsStorage is Storage, ExtendsOwnable, ValidValue {

    IPictionNetwork private pictionNetwork;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
    }

    function setBooleanValue(string key, bool value, string tag) public onlyOwner {
        super.setBooleanValue(key, value, tag);
    }

    function setBytesValue(string key, bytes value, string tag) public onlyOwner {
        super.setBytesValue(key, value, tag);
    }

    function setStringValue(string key, string value, string tag) public onlyOwner {
        super.setStringValue(key, value, tag);
    }

    function setUintValue(string key, uint256 value, string tag) public onlyOwner {
        super.setUintValue(key, value, tag);
    }

    function setAddressValue(string key, address value, string tag) public onlyOwner {
        super.setAddressValue(key, value, tag);
    }

    function getBooleanValue(string key) public onlyOwner view returns(bool value) {
        return super.getBooleanValue(key);
    }

    function getBytesValue(string key) public onlyOwner view returns(bytes value) {
        return super.getBytesValue(key);
    }

    function getStringValue(string key) public onlyOwner view returns(string value) {
        return super.getStringValue(key);
    }

    function getUintValue(string key) public onlyOwner view returns(uint256 value) {
        return super.getUintValue(key);
    }

    function getAddressValue(string key) public onlyOwner view returns(address value) {
        return super.getAddressValue(key);
    }

    function deleteBooleanValue(string key, string tag) public onlyOwner {
        super.deleteBooleanValue(key, tag);
    }

    function deleteBytesValue(string key, string tag) public onlyOwner {
        super.deleteBytesValue(key, tag);
    }

    function deleteStringValue(string key, string tag) public onlyOwner {
        super.deleteStringValue(key, tag);
    }

    function deleteUintValue(string key, string tag) public onlyOwner {
        super.deleteUintValue(key, tag);
    }

    function deleteAddressValue(string key, string tag) public onlyOwner {
        super.deleteAddressValue(key, tag);
    }
}