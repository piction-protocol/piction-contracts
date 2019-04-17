pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./Storage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/ValidValue.sol";

contract AccountsStorage is Storage, Ownable, ValidValue {

    string public constant MANAGER_NAME = "AccountsManager";

    IPictionNetwork private pictionNetwork;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
    }
    
    /**
     *  TODO setter, getter의 require는 storage 통합할 경우 수정 필요
     */

    function setBooleanValue(string key, bool value, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        
        super.setBooleanValue(key, value, tag);
    }

    function setBytesValue(string key, bytes value, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        
        super.setBytesValue(key, value, tag);
    }

    function setStringValue(string key, string value, string tag) public  {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        
        super.setStringValue(key, value, tag);
    }

    function setUintValue(string key, uint256 value, string tag) public  {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        
        super.setUintValue(key, value, tag);
    }

    function setAddressValue(string key, address value, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        
        super.setAddressValue(key, value, tag);
    }

    function getBooleanValue(string key) public view returns(bool value) {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        // Piction network에 read only 계정의 주소가 확정되면 설정
        // require(pictionNetwork.getAddress("") == addr, "Invalid address: Access denied.");

        return super.getBooleanValue(key);
    }

    function getBytesValue(string key) public view returns(bytes value) {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        // Piction network에 read only 계정의 주소가 확정되면 설정
        // require(pictionNetwork.getAddress("") == addr, "Invalid address: Access denied.");

        return super.getBytesValue(key);
    }

    function getStringValue(string key) public view returns(string value) {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        // Piction network에 read only 계정의 주소가 확정되면 설정
        // require(pictionNetwork.getAddress("") == addr, "Invalid address: Access denied.");

        return super.getStringValue(key);
    }

    function getUintValue(string key) public view returns(uint256 value) {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        // Piction network에 read only 계정의 주소가 확정되면 설정
        // require(pictionNetwork.getAddress("") == addr, "Invalid address: Access denied.");

        return super.getUintValue(key);
    }

    function getAddressValue(string key) public  view returns(address value) {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        // Piction network에 read only 계정의 주소가 확정되면 설정
        // require(pictionNetwork.getAddress("") == addr, "Invalid address: Access denied.");

        return super.getAddressValue(key);
    }

    function deleteBooleanValue(string key, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");

        super.deleteBooleanValue(key, tag);
    }

    function deleteBytesValue(string key, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");

        super.deleteBytesValue(key, tag);
    }

    function deleteStringValue(string key, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");

        super.deleteStringValue(key, tag);
    }

    function deleteUintValue(string key, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");

        super.deleteUintValue(key, tag);
    }

    function deleteAddressValue(string key, string tag) public {
        require(pictionNetwork.getAddress(MANAGER_NAME) == msg.sender, "Invalid address: Access denied.");
        
        super.deleteAddressValue(key, tag);
    }
}