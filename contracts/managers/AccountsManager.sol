pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IStorage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IStorage.sol";
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
    IStorage private accountsStorage;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);

        require(pictionNetwork.getAddress(STORAGE_NAME) != address(0), "AccountManager deploy failed: Check Piction Network account storage address");
        iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        accountsStorage = IAccountsStorage(pictionNetwork.getAddress(STORAGE_NAME));
    }

    /**
    * @dev 계정 생성
    * @param id 사용자 계정 id
    * @param hash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function createAccount(string id, string hash, string rawData, address sender) 
        external 
        onlyOwner validString(id) validString(hash) validString(rawData) validAddress(sender) 
    {
        require(availableId(id), "Account creation failed: Invalid user id");
        require(availableAddress(sender), "Account creation failed: Invalid public address");
        require(StringLib.isEmptyString(iStorage.getStringValue(hash)), "Account creation failed: Invalid hash string");
        
        iStorage.setBooleanValue(id, true, CREATE_TAG);
        accountsStorage.setAddressRegistration(sender, hash);
        iStorage.setStringValue(hash, rawData, CREATE_TAG);
    }

    /**
    * @dev 계정 정보 변경
    * @param id 사용자 계정 id
    * @param hash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function updateAccount(string id, string hash, string rawData, address sender) 
        external 
        onlyOwner validString(id) validString(hash) validString(rawData) validAddress(sender) 
    {
        require(accountValidation(id, hash, rawData), "Account update failed: Invalid account info");
        
        iStorage.setStringValue(hash, rawData, UPDATE_TAG);
    }

    /**
    * @dev 계정 삭제
    * @param id 사용자 계정 id
    * @param hash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function deleteAccount(string id, string hash, string rawData, address sender) 
        external 
        onlyOwner validString(id) validString(hash) validString(rawData) validAddress(sender) 
    {
        require(accountValidation(id, hash, rawData), "Account delete failed: Invalid account info");

        iStorage.setStringValue(hash, "", DELETE_TAG);
        accountsStorage.setAddressRegistration(sender, "");
        iStorage.setBooleanValue(id, false, DELETE_TAG);
    }

    /**
    * @dev 계정 정보 검증
    * @param id 사용자 계정 id
    * @param hash 계정정보로 생성한 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    * @return isValid 계정 검증 결과
    */
    function accountValidation(string id, string hash, string rawData, address sender) 
        public 
        onlyOwner validString(id) validString(hash) validString(rawData) validAddress(sender)
        view 
        returns(bool isValid) 
    {
        if(!iStorage.getBooleanValue(id)
            && StringLib.compareString(rawData, iStorage.getStringValue(hash))
            && StringLib.compareString(hash, accountsStorage.getAddressRegistration(sender)))
        {
            isValid = true;
        }
    }

    /**
    * @dev 사용자 id 사용가능 여부 조회
    * @param id 사용자 계정 id
    * @return isAvailable 사용 가능 여부
    */
    function availableId(string id) public onlyOwner validString(id) view returns(bool isAvailable) {
        return !iStorage.getBooleanValue(id);
    }

    /**
    * @dev 사용자 주소 사용가능 여부 조회
    * @param sender public address
    * @return isAvailable 사용 가능 여부
    */
    function availableAddress(address sender) public onlyOwner validAddress(sender) view returns(bool isAvailable) {
        string memory hash = accountsStorage.getAddressRegistration(sender);
        return StringLib.isEmptyString(hash);
    }

    /**
    * @dev 사용자 주소 사용가능 여부 조회
    * @param hash 사용자 고유 hash
    * @return isAvailable 사용 가능 여부
    */
    function availableHash(string hash) public onlyOwner validString(hash) view returns(bool isAvailable) {
        string memory rawData = iStorage.getStringValue(hash);
        return StringLib.isEmptyString(rawData);
    }
}