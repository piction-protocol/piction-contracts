pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";

contract AccountsStorage is IAccountsStorage, Ownable, ValidValue {

    string public constant MANAGER_NAME = "AccountsManager";

    IPictionNetwork private pictionNetwork;

    mapping (string => uint256) private uintValue;
    mapping (string => bytes)   private bytesValue;
    mapping (string => string)  private stringValue;
    mapping (string => address) private addressValue;
    mapping (string => bool)    private booleanValue;

    mapping (address => string) private addressRegistration;

    modifier onlyAccountsManager(address manager) {
        require(manager != address(0), "Invaild address: Address 0 is not allowed.");
        require(manager != address(this), "Invaild address: Same address as AccountsStorage contact");
        require(pictionNetwork.getAddress(MANAGER_NAME) == manager, "Invalid address: Access denied.");
        _;
    }

    modifier onlyReadRole(address addr) {
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
    
    /**
    * @dev boolean mapping data 설정
    * @param key 설정하고자 하는 booleanValue key
    * @param value 설정하고자 하는 booleanValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setBooleanValue(string key, bool value, string tag) external onlyAccountsManager(msg.sender) {
        booleanValue[key] = value;
        
        emit SetBooleanValue(tag, key, TimeLib.currentTime());
    }

    /**
    * @dev bytes mapping data 설정
    * @param key 설정하고자 하는 bytesValue key
    * @param value 설정하고자 하는 bytesValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setBytesValue(string key, bytes value, string tag) external onlyAccountsManager(msg.sender)  {
        bytesValue[key] = value;

        emit SetBytesValue(tag, key, TimeLib.currentTime());
    }

    /**
    * @dev string mapping data 설정
    * @param key 설정하고자 하는 stringValue key
    * @param value 설정하고자 하는 stringValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setStringValue(string key, string value, string tag) external onlyAccountsManager(msg.sender) {
        stringValue[key] = value;

        emit SetStringValue(tag, key, TimeLib.currentTime());
    }

    /**
    * @dev uint mapping data 설정
    * @param key 설정하고자 하는 uintValue key
    * @param value 설정하고자 하는 utinValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setUintValue(string key, uint256 value, string tag) external onlyAccountsManager(msg.sender) {
        uintValue[key] = value;

        emit SetUintValue(tag, key, TimeLib.currentTime());
    }

    /**
    * @dev address mapping data 설정
    * @param key 설정하고자 하는 addressValue key
    * @param value 설정하고자 하는 addressValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setAddressValue(string key, address value, string tag) external onlyAccountsManager(msg.sender)  {
        addressValue[key] = value;

        emit SetAddressValue(tag, key, TimeLib.currentTime());
    }

    /**
    * @dev 계정의 public address 설정
    * @param sender 계정의 주소
    * @param hash 사용자 고유 hash
    */
    function setAddressRegistration(address sender, string hash) 
        external 
        onlyAccountsManager(msg.sender) validAddress(sender) validString(hash) 
    {
        addressRegistration[sender] = hash;
    }

    /**
    * @dev boolean mapping data 조회
    * @param key 조회 하는 booleanValue key
    * @return value key에 해당하는 boolean value
    */
    function getBooleanValue(string key) external onlyReadRole(msg.sender) view returns(bool value) {
        value = booleanValue[key];
    }

    /**
    * @dev bytes mapping data 조회
    * @param key 조회 하는 bytesValue key
    * @return value key에 해당하는 bytes value
    */
    function getBytesValue(string key) external onlyReadRole(msg.sender) view returns(bytes value) {
        value = bytesValue[key];
    }

    /**
    * @dev string mapping data 조회
    * @param key 조회 하는 stringValue key
    * @return value key에 해당하는 string value
    */
    function getStringValue(string key) external onlyReadRole(msg.sender) view returns(string value) {
        value = stringValue[key];
    }

    /**
    * @dev uint mapping data 조회
    * @param key 조회 하는 uintValue key
    * @return value key에 해당하는 uint256 value
    */
    function getUintValue(string key) external onlyReadRole(msg.sender) view returns(uint256 value) {
        value = uintValue[key];
    }

    /**
    * @dev address mapping data 조회
    * @param key 조회 하는 addressValue key
    * @return value key에 해당하는 address value
    */
    function getAddressValue(string key) external onlyReadRole(msg.sender) view returns(address value) {
        value = addressValue[key];
    }

    /**
    * @dev 주소 등록 여부 조회
    * @param sender 조회하고자 하는 public address
    * @return hash sender로 등록된 hash
    */
    function getAddressRegistration(address sender) external onlyReadRole(msg.sender) view returns(string hash) {
        return addressRegistration[sender];
    }
}