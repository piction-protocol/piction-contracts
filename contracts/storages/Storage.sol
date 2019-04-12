pragma solidity ^0.4.24;

import "../interfaces/IStorage.sol";

contract Storage is IStorage {

    mapping (string => uint256) private uintValue;
    mapping (string => bytes)   private bytesValue;
    mapping (string => string)  private stringValue;
    mapping (string => address) private addressValue;
    mapping (string => bool)    private booleanValue;

    /**
    * @dev boolean mapping data 설정
    * @param key 설정하고자 하는 booleanValue key
    * @param value 설정하고자 하는 booleanValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setBooleanValue(string key, bool value, string tag) public {
        booleanValue[key] = value;
        
        emit SetBooleanValue(tag, key);
    }

    /**
    * @dev bytes mapping data 설정
    * @param key 설정하고자 하는 bytesValue key
    * @param value 설정하고자 하는 bytesValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setBytesValue(string key, bytes value, string tag) public {
        bytesValue[key] = value;

        emit SetBytesValue(tag, key);
    }

    /**
    * @dev string mapping data 설정
    * @param key 설정하고자 하는 stringValue key
    * @param value 설정하고자 하는 stringValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setStringValue(string key, string value, string tag) public {
        stringValue[key] = value;

        emit SetStringValue(tag, key);
    }

    /**
    * @dev uint mapping data 설정
    * @param key 설정하고자 하는 uintValue key
    * @param value 설정하고자 하는 utinValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setUintValue(string key, uint256 value, string tag) public  {
        uintValue[key] = value;

        emit SetUintValue(tag, key);
    }

    /**
    * @dev address mapping data 설정
    * @param key 설정하고자 하는 addressValue key
    * @param value 설정하고자 하는 addressValue value
    * @param tag mapping 변수 설정에 대한 tag
    */
    function setAddressValue(string key, address value, string tag) public {
        addressValue[key] = value;

        emit SetAddressValue(tag, key);
    }

    /**
    * @dev boolean mapping data 조회
    * @param key 조회 하는 booleanValue key
    * @return value key에 해당하는 boolean value
    */
    function getBooleanValue(string key) public view returns(bool value) {
        value = booleanValue[key];
    }

    /**
    * @dev bytes mapping data 조회
    * @param key 조회 하는 bytesValue key
    * @return value key에 해당하는 bytes value
    */
    function getBytesValue(string key) public view returns(bytes value) {
        value = bytesValue[key];
    }

    /**
    * @dev string mapping data 조회
    * @param key 조회 하는 stringValue key
    * @return value key에 해당하는 string value
    */
    function getStringValue(string key) public view returns(string value) {
        value = stringValue[key];
    }

    /**
    * @dev uint mapping data 조회
    * @param key 조회 하는 uintValue key
    * @return value key에 해당하는 uint256 value
    */
    function getUintValue(string key) public view returns(uint256 value) {
        value = uintValue[key];
    }

    /**
    * @dev address mapping data 조회
    * @param key 조회 하는 addressValue key
    * @return value key에 해당하는 address value
    */
    function getAddressValue(string key) public view returns(address value) {
        value = addressValue[key];
    }

    /**
    * @dev boolean mapping data 삭제
    * @param key 삭제하고자 하는 booleanValue key
    * @param value 삭제하고자 하는 booleanValue value
    * @param tag mapping 변수 삭제 tag
    */
    function deleteBooleanValue(string key, bool value, string tag) public {
        booleanValue[key] = value;
        
        emit SetBooleanValue(tag, key);
    }

    /**
    * @dev bytes mapping data 삭제
    * @param key 삭제하고자 하는 bytesValue key
    * @param value 삭제하고자 하는 bytesValue value
    * @param tag mapping 변수 삭제 tag
    */
    function deleteBytesValue(string key, bytes value, string tag) public {
        bytesValue[key] = value;

        emit SetBytesValue(tag, key);
    }

    /**
    * @dev string mapping data 삭제
    * @param key 삭제하고자 하는 stringValue key
    * @param value 삭제하고자 하는 stringValue value
    * @param tag mapping 변수 삭제 tag
    */
    function deleteStringValue(string key, string value, string tag) public {
        stringValue[key] = value;

        emit SetStringValue(tag, key);
    }

    /**
    * @dev uint mapping data 삭제
    * @param key 삭제하고자 하는 uintValue key
    * @param value 삭제하고자 하는 utinValue value
    * @param tag mapping 변수 삭제 tag
    */
    function deleteUintValue(string key, uint256 value, string tag) public  {
        uintValue[key] = value;

        emit SetUintValue(tag, key);
    }

    /**
    * @dev address mapping data 삭제
    * @param key 삭제하고자 하는 addressValue key
    * @param value 삭제하고자 하는 addressValue value
    * @param tag mapping 변수 삭제 tag
    */
    function deleteAddressValue(string key, address value, string tag) public {
        addressValue[key] = value;

        emit SetAddressValue(tag, key);
    }
}