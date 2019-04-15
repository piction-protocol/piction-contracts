pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IStorage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";

import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";
import "../utils/StringLib.sol";

contract AccountsManager is IAccountsManager, Ownable, ValidValue {
    
    string public constant STORAGE_NAME = "AccountsStorage";
    string public constant CREATE_TAG = "CreateAccount";
    string public constant UPDATE_TAG = "UpdateAccount";
    string public constant DELETE_TAG = "DeleteAccount";

    IStorage private iStorage;
    IPictionNetwork private pictionNetwork;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);

        require(pictionNetwork.getAddress(STORAGE_NAME) != address(0), "AccountManager deploy failed: Check account storage address");
        iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
    }

    /**
    * @dev 계정 생성
    * @param id 사용자 계정 id
    * @param userHash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function createAccount(string id, string userHash, string rawData, address sender) 
        external 
        onlyOwner validString(id) validString(userHash) validString(rawData) validAddress(sender) 
    {
        require(availableId(id), "Account creation failed: Already exists user id");
        require(iStorage.getAddressValue(userHash) == address(0), "Account creation failed: Already exists user hash and address");
        require(StringLib.isEmptyString(iStorage.getStringValue(userHash)), "Account creation failed: Already exists userHash and raw data");
        
        iStorage.setBooleanValue(id, true, CREATE_TAG);
        iStorage.setAddressValue(userHash, sender, CREATE_TAG);
        iStorage.setStringValue(userHash, rawData, CREATE_TAG);
    }

    /**
    * @dev 계정 정보 변경
    * @param id 사용자 계정 id
    * @param userHash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function updateAccount(string id, string userHash, string rawData, address sender) 
        external 
        onlyOwner validString(id) validString(userHash) validString(rawData) validAddress(sender) 
    {
        require(!availableId(id), "Update account failed: Invalid user id");
        require(iStorage.getAddressValue(userHash) == sender, "Update account failed: Invalid user hash and address");
        require(StringLib.isEmptyString(iStorage.getStringValue(userHash)), "Update account failed: Invalid user hash and raw data");
        
        iStorage.setStringValue(userHash, rawData, UPDATE_TAG);
    }

    /**
    * @dev 계정 삭제
    * @param id 사용자 계정 id
    * @param userHash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function deleteAccount(string id, string userHash, string rawData, address sender) 
        external 
        onlyOwner validString(id) validString(userHash) validString(rawData) validAddress(sender) 
    {
        require(!availableId(id), "Delete account failed: Invalid user id");
        require(iStorage.getAddressValue(userHash) == sender, "Delete account failed: Invalid user hash and address");
        require(StringLib.isEmptyString(iStorage.getStringValue(userHash)), "Delete account failed: Invalid user hash and raw data");

        iStorage.deleteBooleanValue(id, DELETE_TAG);
        iStorage.deleteAddressValue(userHash, DELETE_TAG);
        iStorage.deleteStringValue(userHash, DELETE_TAG);
    }

    /**
    * @dev 사용자 id 사용가능 여부 조회
    * @param id 사용자 계정 id
    * @return isAvailable 사용 가능 여부
    */
    function availableId(string id) public validString(id) view returns(bool isAvailable) {
        return !iStorage.getBooleanValue(id);
    }

    /**
    * @dev 사용자 주소 사용가능 여부 조회
    * @param userHash 사용자 고유 hash
    * @return isAvailable 사용 가능 여부
    */
    function availableUserHash(string userHash) public validString(userHash) view returns(bool isAvailable) {
        return (StringLib.isEmptyString(iStorage.getStringValue(userHash)) && iStorage.getAddressValue(userHash) == address(0));
    }

    /**
    * @dev 사용자 주소 조회
    * @param userHash 사용자 고유 hash
    * @return publicKey 사용자 주소
    */
    function getUserAddress(string userHash) public validString(userHash) view returns(address publicKey) {
        return iStorage.getAddressValue(userHash);
    }
}