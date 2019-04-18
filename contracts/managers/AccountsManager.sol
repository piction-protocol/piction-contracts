pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IStorage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";

import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";
import "../utils/StringLib.sol";

contract AccountsManager is IAccountsManager, Ownable, ValidValue {
    using StringLib for string;

    string public constant STORAGE_NAME = "AccountsStorage";
    string public constant CREATE_TAG = "CreateAccount";
    string public constant UPDATE_TAG = "UpdateAccount";
    string public constant DELETE_TAG = "DeleteAccount";

    IStorage private iStorage;
    IPictionNetwork private pictionNetwork;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);

        address account = pictionNetwork.getAddress(STORAGE_NAME);
        require(account != address(0), "AccountsManager constructor 0");

        iStorage = IStorage(account);
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
        require(availableId(id), "AccountsManager createAccount 0");
        require(iStorage.getAddressValue(userHash) == address(0), "AccountsManager createAccount 1");
        require(iStorage.getStringValue(userHash).isEmptyString(), "AccountsManager createAccount 2");
        
        iStorage.setBooleanValue(id, true, CREATE_TAG);
        iStorage.setAddressValue(userHash, sender, CREATE_TAG);
        iStorage.setStringValue(userHash, rawData, CREATE_TAG);
    }

    /**
    * @dev 계정 정보 변경
    * @param id 사용자 계정 id
    * @param userHash 사용자 고유 hash
    * @param rawData 변경할 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function updateAccount(string id, string userHash, string rawData, address sender) 
        external 
        onlyOwner validString(id) validString(userHash) validString(rawData) validAddress(sender) 
    {
        require(!availableId(id), "AccountsManager updateAccount 0");
        require(iStorage.getAddressValue(userHash) == sender, "AccountsManager updateAccount 1");
        require(!iStorage.getStringValue(userHash).isEmptyString(), "AccountsManager updateAccount 2");
        
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
        require(!availableId(id), "AccountsManager deleteAccount 0");
        require(iStorage.getAddressValue(userHash) == sender, "AccountsManager deleteAccount 1");
        require(!iStorage.getStringValue(userHash).isEmptyString(), "AccountsManager deleteAccount 2");
        require(iStorage.getStringValue(userHash).compareString(rawData), "AccountsManager deleteAccount 3");

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
        return (iStorage.getStringValue(userHash).isEmptyString() && iStorage.getAddressValue(userHash) == address(0));
    }

    /**
    * @dev 사용자 주소 조회
    * @param userHash 사용자 고유 hash
    * @return publicKey 사용자 주소
    */
    function getUserAddress(string userHash) public validString(userHash) view returns(address publicKey) {
        return iStorage.getAddressValue(userHash);
    }

    /**
    * @dev 사용자 계정 검증
    * @param userHash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @return isValid 검증 결과
    */
    function accountValidation(string userHash, string rawData)
        external 
        onlyOwner validString(userHash) validString(rawData) 
        view 
        returns(bool isValid) 
    {
        return iStorage.getStringValue(userHash).compareString(rawData);
    }

    /**
     * @dev 저장소 주소 변경
     * @param aStorage User 정보가 저장되는 주소
     */
    function changeStorage(address aStorage) 
        validAddress(aStorage)
        external 
        onlyOwner
    {
        iStorage = IStorage(aStorage);
    }
}