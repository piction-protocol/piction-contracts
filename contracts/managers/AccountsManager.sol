pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsStorage.sol";
import "../interfaces/IAccountsManager.sol";
import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";

contract AccountsManager is IAccountsManager, Ownable, ValidValue {
    
    string public constant STORAGE_NAME = "AccountsStorage";

    IPictionNetwork private pictionNetwork;
    IAccountsStorage private accountsStorage;

    mapping (string => string) private accounts;

    constructor(address piction) validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
        accountsStorage = IAccountsStorage(pictionNetwork.getAddress(STORAGE_NAME));
    }

    /**
    * @dev 계정 생성
    * @param id 사용자 계정 id
    * @param hash 계정정보로 생성한 hash
    * @param json 사용자 계정 정보
    */
    function createAccount(string id, string hash, string json) external onlyOwner {
        require(availableId(id), "Account creation failed: Invalid user id");
        require(!_isEmptyString(accountsStorage.getStringField(hash)), "Account creation failed: Invalid hash string");

        accounts[id] = hash;
        accountsStorage.setStringField(hash, json);
        
        emit CreateAccount(msg.sender, id, TimeLib.currentTime());
    }

    /**
    * @dev 계정 정보 검증
    * @param id 사용자 계정 id
    * @param hash 계정정보로 생성한 hash
    * @param json 사용자 계정 정보
    * @return isValid 계정 검증 결과
    */
    function accountValidation(string id, string hash, string json) 
        public 
        onlyOwner validString(id) validString(hash) validString(json) 
        view 
        returns(bool isValid) 
    {
        if(!_isEmptyString(accounts[id]) 
            && _compareString(accounts[id], hash) 
            && _compareString(json, accountsStorage.getStringField(hash))) 
        {
            isValid = true;
        }
    }

    /**
    * @dev 사용 가능 id 정보 조회
    * @param id 사용자 계정 id
    * @return isAvailable id 사용 가능 여부
    */
    function availableId(string id) public onlyOwner validString(id) view returns(bool isAvailable) {
        return _isEmptyString(accounts[id]);
    }

    /**
    * @dev 빈 문자열 확인 함수
    * @param value 확인하고자 하는 string value
    * @return isEmpty 빈 문자열 확인 결과
    */
    function _isEmptyString(string value) private returns(bool isEmpty) {
        return (bytes(value).length == 0);
    }

    /**
    * @dev 문자열 비교 함수
    * @param value1 비교하고자 하는 문자열
    * @param value2 비교하고자 하는 문자열
    * @return isSameValue 동일 문자열 확인 결과
    */
    function _compareString(string value1, string value2) private returns(bool isSameValue) {
        return (keccak256(value1) == keccak256(value2));
    }
}