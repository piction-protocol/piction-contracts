pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IStorage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";
import "../interfaces/IUpdateAddress.sol";

import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";
import "../utils/StringLib.sol";

contract AccountsManager is IAccountsManager, Ownable, ValidValue, IUpdateAddress{
    using StringLib for string;

    string private constant STORAGE_NAME = "AccountsStorage";
    string private constant CREATE_TAG = "CreateAccount";
    string private constant UPDATE_TAG = "UpdateAccount";
    string private constant DELETE_TAG = "DeleteAccount";

    IStorage private iStorage;
    IPictionNetwork private pictionNetwork;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
        iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
    }

    /**
    * @dev 계정 생성
    * @param email 사용자 계정 메일 주소
    * @param userHash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function createAccount(
        string email, 
        string userHash, 
        string rawData, 
        address sender
    ) 
        external 
        onlyOwner 
        validString(userHash) 
        validString(rawData) 
        validAddress(sender) 
    {
        require(availableEmail(email), "AccountsManager createAccount 0");
        require(iStorage.getAddressValue(userHash) == address(0), "AccountsManager createAccount 1");
        require(iStorage.getStringValue(userHash).isEmptyString(), "AccountsManager createAccount 2");
        require(iStorage.getStringValue(email).isEmptyString(), "AccountsManager createAccount 3");
        
        iStorage.setBooleanValue(email, true, CREATE_TAG);
        iStorage.setAddressValue(userHash, sender, CREATE_TAG);
        iStorage.setStringValue(email, userHash, CREATE_TAG);
        iStorage.setStringValue(userHash, rawData, CREATE_TAG);
    }

    /**
    * @dev 계정 정보 변경
    * @param beforeEmail 사용자 계정 현재 메일 주소
    * @param afterEmail 사용자 계정 수정할 메일 주소
    * @param userHash 사용자 고유 hash
    * @param rawData 변경할 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function updateAccount(
        string beforeEmail,
        string afterEmail, 
        string userHash, 
        string rawData, 
        address sender
    ) 
        external 
        onlyOwner 
        validString(userHash) 
        validString(rawData) 
        validAddress(sender) 
    {
        require(!availableEmail(beforeEmail), "AccountsManager updateAccount 0");
        require(iStorage.getAddressValue(userHash) == sender, "AccountsManager updateAccount 1");
        require(!iStorage.getStringValue(userHash).isEmptyString(), "AccountsManager updateAccount 2");

        iStorage.setBooleanValue(afterEmail, true, UPDATE_TAG);  
        iStorage.deleteBooleanValue(beforeEmail, UPDATE_TAG);  
        iStorage.setStringValue(userHash, rawData, UPDATE_TAG);
        
        if(beforeEmail.compareString(afterEmail)) {
            iStorage.setStringValue(userHash, rawData, UPDATE_TAG);
        } else {
            require(availableEmail(afterEmail) && iStorage.getStringValue(afterEmail).isEmptyString(), "AccountsManager updateAccount 3");
            
            iStorage.setBooleanValue(afterEmail, true, UPDATE_TAG);
            iStorage.deleteBooleanValue(beforeEmail, UPDATE_TAG);

            iStorage.setStringValue(afterEmail, userHash, UPDATE_TAG);
            iStorage.deleteStringValue(beforeEmail, UPDATE_TAG);

            iStorage.setStringValue(userHash, rawData, UPDATE_TAG);
        }
    }

    /**
    * @dev 계정 삭제
    * @param email 사용자 계정 메일 주소
    * @param userHash 사용자 고유 hash
    * @param rawData 사용자 계정 정보
    * @param sender 사용자 주소
    */
    function deleteAccount(
        string email, 
        string userHash, 
        string rawData, 
        address sender
    ) 
        external 
        onlyOwner 
        validString(userHash) 
        validString(rawData) 
        validAddress(sender) 
    {
        require(!availableEmail(email), "AccountsManager deleteAccount 0");
        require(iStorage.getAddressValue(userHash) == sender, "AccountsManager deleteAccount 1");
        require(!iStorage.getStringValue(userHash).isEmptyString(), "AccountsManager deleteAccount 2");
        require(iStorage.getStringValue(userHash).compareString(rawData), "AccountsManager deleteAccount 3");

        iStorage.deleteBooleanValue(email, DELETE_TAG);
        iStorage.deleteAddressValue(userHash, DELETE_TAG);
        iStorage.deleteStringValue(userHash, DELETE_TAG);
    }

    /**
    * @dev 사용자 email 사용가능 여부 조회
    * @param email 사용자 계정 메일 주소
    * @return isAvailable 사용 가능 여부
    */
    function availableEmail(string email) public view validString(email) returns(bool isAvailable) {
        return !iStorage.getBooleanValue(email);
    }

    /**
    * @dev 사용자 주소 사용가능 여부 조회
    * @param userHash 사용자 고유 hash
    * @return isAvailable 사용 가능 여부
    */
    function availableUserHash(string userHash) public view validString(userHash) returns(bool isAvailable) {
        return (iStorage.getStringValue(userHash).isEmptyString() && iStorage.getAddressValue(userHash) == address(0));
    }

    /**
    * @dev 사용자 주소 조회
    * @param userHash 사용자 고유 hash
    * @return publicKey 사용자 주소
    */
    function getUserAddress(string userHash) public view validString(userHash) returns(address publicKey) {
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
        view 
        onlyOwner 
        validString(userHash) 
        validString(rawData) 
        returns(bool isValid) 
    {
        return iStorage.getStringValue(userHash).compareString(rawData);
    }

    /**
     * @dev 저장소 업데이트
     */
    function updateAddress() external {
        require(msg.sender == address(pictionNetwork), "AccountsManager updateAddress 0");

        address aStorage = pictionNetwork.getAddress(STORAGE_NAME);
        emit UpdateAddress(address(iStorage), aStorage);
        iStorage = IStorage(aStorage);
    }
}