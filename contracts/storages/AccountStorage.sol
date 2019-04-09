pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsStorage.sol";
import "../utils/ValidValue.sol";

contract AccountsStorage is IAccountStorage, Ownable, ValidValue {

    string public constant MANAGER_NAME = "AccountsManager";

    IPictionNetwork private pictionNetwork;

    mapping (string => uint256) private uint_field;
    mapping (string => string)  private string_field;
    mapping (string => address) private address_field;
    mapping (string => bool)    private boolean_field;

    modifier onlyAccountManager(address manager) {
        require(addr != address(0), "Invaild address: Address 0 is not allowed.");
        require(addr != address(this), "Invaild address: Same address as AccountStorage contact");
        require(pictionNetwork.getAddress(MANAGER_NAME) == manager, "Invalid address: Access denied.");
        _;
    }

    constructor(address piction) validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
    }
    
    /**
    * @dev boolean mapping data 설정
    * @param key 설정하고자 하는 boolean_field key
    * @param value 설정하고자 하는 boolean_field value
    */
    function setBooleanField(string key, bool value) external onlyAccountManager(msg.sender) {
        boolean_field[key] = value;
    }

    /**
    * @dev string mapping data 설정
    * @param key 설정하고자 하는 string_field key
    * @param value 설정하고자 하는 string_field value
    */
    function setStringField(string key, string value) external onlyAccountManager(msg.sender) {
        string_field[key] = value;
    }

    /**
    * @dev uint mapping data 설정
    * @param key 설정하고자 하는 uint_field key
    * @param value 설정하고자 하는 utin_field value
    */
    function setUintField(string key, uint256 value) external onlyAccountManager(msg.sender) {
        uint_field[key] = value;
    }

    /**
    * @dev address mapping data 설정
    * @param key 설정하고자 하는 address_field key
    * @param value 설정하고자 하는 address_field value
    */
    function setAddressField(string key, address value) external onlyAccountManager(msg.sender)  {
        boolean_field[key] = value;
    }

    /**
    * @dev boolean mapping data 조회
    * @param key 조회 하는 boolean_field key
    * @return value key에 해당하는 boolean value
    */
    function getBooleanField(string key) external onlyAccountManager(msg.sender) view returns(bool value) {
        value = boolean_field[key];
    }

    /**
    * @dev string mapping data 조회
    * @param key 조회 하는 string_field key
    * @return value key에 해당하는 string value
    */
    function getStringField(string key) external onlyAccountManager(msg.sender) view returns(string value) {
        value = string_field[key];
    }

    /**
    * @dev uint mapping data 조회
    * @param key 조회 하는 uint_field key
    * @return value key에 해당하는 uint256 value
    */
    function getUintField(string key) external onlyAccountManager(msg.sender) view returns(uint256 value) {
        value = uint_field[key];
    }

    /**
    * @dev address mapping data 조회
    * @param key 조회 하는 address_field key
    * @return value key에 해당하는 address value
    */
    function getAddressField(string key) external onlyAccountManager(msg.sender) view returns(address value) {
        value = boolean_field[key];
    }
}