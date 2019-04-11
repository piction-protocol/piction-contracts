pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./Storage.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsStorage.sol";

import "../utils/ValidValue.sol";

contract AccountsStorage is Storage, IAccountsStorage, Ownable, ValidValue {

    string public constant MANAGER_NAME = "AccountsManager";

    IPictionNetwork private pictionNetwork;

    mapping (address => string) private addressRegistration;

    modifier onlyAccountsManager(address manager) {
        require(manager != address(0), "Invaild address: Address 0 is not allowed.");
        require(manager != address(this), "Invaild address: Same address as AccountsStorage contact");
        require(pictionNetwork.getAddress(MANAGER_NAME) == manager, "Invalid address: Access denied.");
        _;
    }

    modifier readOnlyRole(address addr) {
        require(addr != address(0), "Invaild address: Address 0 is not allowed.");
        require(addr != address(this), "Invaild address: Same address as AccountsStorage contact");
        require(pictionNetwork.getAddress(MANAGER_NAME) == addr, "Invalid address: Access denied.");
        
        // Piction network에 read only 계정의 주소가 확정되면 설정
        // require(pictionNetwork.getAddress("") == addr, "Invalid address: Access denied.");
        _;
    }

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
    }
    
    function setBooleanValue(string key, bool value, string tag) public onlyAccountsManager(msg.sender) {
        super.setBooleanValue(key, value, tag);
    }

    function setBytesValue(string key, bytes value, string tag) public onlyAccountsManager(msg.sender)  {
        super.setBytesValue(key, value, tag);
    }

    function setStringValue(string key, string value, string tag) public onlyAccountsManager(msg.sender) {
        super.setStringValue(key, value, tag);
    }

    function setUintValue(string key, uint256 value, string tag) public onlyAccountsManager(msg.sender) {
        super.setUintValue(key, value, tag);
    }

    function setAddressValue(string key, address value, string tag) public onlyAccountsManager(msg.sender)  {
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

    /**
    * @dev 계정의 public address 설정
    * @param sender 계정의 주소
    * @param hash 사용자 고유 hash
    */
    function setAddressRegistration(address sender, string hash) 
        public 
        onlyAccountsManager(msg.sender) validAddress(sender) validString(hash) 
    {
        addressRegistration[sender] = hash;
    }

    /**
    * @dev 주소 등록 여부 조회
    * @param sender 조회하고자 하는 public address
    * @return hash sender로 등록된 hash
    */
    function getAddressRegistration(address sender) public readOnlyRole(msg.sender) view returns(string hash) {
        return addressRegistration[sender];
    }
}