pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./Storage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/ValidValue.sol";

contract RelationStorage is Storage, Ownable, ValidValue {

    string public constant CONTENTS_MANAGER_NAME = "ContentsManager";
    string public constant POST_MANAGER_NAME = "PostManager";

    IPictionNetwork private pictionNetwork;

    modifier onlyManager(address sender) {
        require(sender != address(0), "Invaild address: Address 0 is not allowed.");
        require(sender != address(this), "Invaild address: Same address as RelationStorage contact");
        //for test, gas limit require(pictionNetwork.getAddress(CONTENTS_MANAGER_NAME) == sender || pictionNetwork.getAddress(POST_MANAGER_NAME) == sender, "Invalid address: Access denied.");
        _;
    }

    modifier readOnlyRole(address sender) {
        require(sender != address(0), "Invaild address: Address 0 is not allowed.");
        require(sender != address(this), "Invaild address: Same address as RelationStorage contact");
        //for test, gas limit require(pictionNetwork.getAddress(CONTENTS_MANAGER_NAME) == sender || pictionNetwork.getAddress(POST_MANAGER_NAME) == sender, "Invalid address: Access denied.");
        
        // Piction network에 read only 계정의 주소가 확정되면 설정
        // require(pictionNetwork.getAddress("") == addr, "Invalid address: Access denied.");
        _;
    }

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
    }

    function setBooleanValue(string key, bool value, string tag) public onlyManager(msg.sender) {
        super.setBooleanValue(key, value, tag);
    }

    function setBytesValue(string key, bytes value, string tag) public onlyManager(msg.sender)  {
        super.setBytesValue(key, value, tag);
    }

    function setStringValue(string key, string value, string tag) public onlyManager(msg.sender) {
        super.setStringValue(key, value, tag);
    }

    function setUintValue(string key, uint256 value, string tag) public onlyManager(msg.sender) {
        super.setUintValue(key, value, tag);
    }

    function setAddressValue(string key, address value, string tag) public onlyManager(msg.sender)  {
        super.setAddressValue(key, value, tag);
    }

    function getBooleanValue(string key) public readOnlyRole(msg.sender) view returns(bool value) {
        return super.getBooleanValue(key);
    }

    function getBytesValue(string key) public readOnlyRole(msg.sender) view returns(bytes value) {
        return super.getBytesValue(key);
    }

    function getStringValue(string key) public readOnlyRole(msg.sender) view returns(string value) {
        return super.getStringValue(key);
    }

    function getUintValue(string key) public readOnlyRole(msg.sender) view returns(uint256 value) {
        return super.getUintValue(key);
    }

    function getAddressValue(string key) public readOnlyRole(msg.sender) view returns(address value) {
        return super.getAddressValue(key);
    }

    function deleteBooleanValue(string key, string tag) public onlyManager(msg.sender) {
        super.deleteBooleanValue(key, tag);
    }

    function deleteBytesValue(string key, string tag) public onlyManager(msg.sender)  {
        super.deleteBytesValue(key, tag);
    }

    function deleteStringValue(string key, string tag) public onlyManager(msg.sender) {
        super.deleteStringValue(key, tag);
    }

    function deleteUintValue(string key, string tag) public onlyManager(msg.sender) {
        super.deleteUintValue(key, tag);
    }

    function deleteAddressValue(string key, string tag) public onlyManager(msg.sender)  {
        super.deleteAddressValue(key, tag);
    }
}