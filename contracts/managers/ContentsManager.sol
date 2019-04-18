pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";
import "../interfaces/IContentsManager.sol";
import "../interfaces/IStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/StringLib.sol";

contract ContentsManager is Ownable, ValidValue, IContentsManager {
    using StringLib for string;

    string public constant STORAGE_NAME = "ContentsStorage";
    string public constant RELATION_NAME = "RelationStorage";
    string public constant ACCOUNT_NAME = "AccountsManager";
    string public constant CREATE_TAG = "createContents";
    string public constant UPDATE_TAG = "updateContents";
    string public constant DELETE_TAG = "deleteContents";

    IPictionNetwork pictionNetwork;

    IStorage private contentsStorage;
    IStorage private relationStorage;

    IAccountsManager private accountManager;


    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);

        address contents = pictionNetwork.getAddress(STORAGE_NAME);
        require(contents != address(0), "ContentsManager deploy failed: Check contents storage address");

        address relation = pictionNetwork.getAddress(RELATION_NAME);
        require(relation != address(0), "ContentsManager deploy failed: Check relation storage address");

        address aManager = pictionNetwork.getAddress(ACCOUNT_NAME);
        require(aManager != address(0), "ContentsManager deploy failed: Check accounts manager address");

        contentsStorage = IStorage(contents);
        relationStorage = IStorage(relation);

        accountManager = IAccountsManager(aManager);
    }

    /**
     * @dev 콘텐츠 생성 
     * @param userHash 생성하는 유저의 유일 값
     * @param contentsHash 생성하는 콘텐츠의 유일 값
     * @param rawData 생성되는 콘텐츠의 데이터
     */
    function createContents(string userHash, string contentsHash, string rawData) 
        external
        validString(userHash) 
        validString(contentsHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "createContents : Not Match Sender");

        require(contentsStorage.getAddressValue(contentsHash) == address(0) ,"createContents : Already address.");
        require(contentsStorage.getStringValue(contentsHash).isEmptyString(),"createContents : Already rawdata.");

        contentsStorage.setAddressValue(contentsHash, msg.sender, CREATE_TAG);
        contentsStorage.setStringValue(contentsHash, rawData, CREATE_TAG);

        relationStorage.setStringValue(contentsHash, userHash, CREATE_TAG);

        //if necessary, deploy contract.
    }

    /**
     * @dev 콘텐츠의 데이터를 업데이트
     * @param userHash 업데이트하는 유저의 고유 값
     * @param contentsHash 업데이트하는 콘텐츠의 고유 값
     * @param rawData 엡데이트 데이터
     */
    function updateContents(string userHash, string contentsHash, string rawData) 
        external
        validString(userHash) 
        validString(contentsHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "updatecontents : Not Match Sender");

        require(isContentsUser(contentsHash) ,"updateContents : Not Match User.");
        require(!contentsStorage.getStringValue(contentsHash).isEmptyString(),"updateContents : rawdata Empty");

        contentsStorage.setStringValue(contentsHash, rawData, UPDATE_TAG);
    }

    /**
     * @dev Contents 삭제
     * @param userHash 삭제를 요청하는 유저의 유일한 값
     * @param contentsHash 삭제하고자 하는 콘텐츠의 유일한 값
     */
    function deleteContents(string userHash, string contentsHash)
        external
        validString(userHash) 
        validString(contentsHash)
    {
        require(isPictionUser(userHash) || isOwner(), "deleteContents : Not Match Sender");

        require(isContentsUser(contentsHash) || isOwner() ,"deleteContents : Contents Not Match User.");
        require(!contentsStorage.getStringValue(contentsHash).isEmptyString(),"deleteContents : Rawdata Empty");

        contentsStorage.deleteAddressValue(contentsHash, DELETE_TAG);
        contentsStorage.deleteStringValue(contentsHash, DELETE_TAG);

        relationStorage.deleteStringValue(contentsHash, DELETE_TAG);
    }

    /**
     * @dev 픽션에 등록된 유저인지 확인
     * @param userHash 확인할 유저의 유일 값
     * @return bool 등록 유저유무
     */
    function isPictionUser(string userHash) private view returns(bool) {
        return msg.sender == accountManager.getUserAddress(userHash);
    }

    /**
     * @dev 콘텐츠를 등록한 유저인지 확인
     * @param contentsHash 확인할 콘텐츠의 유일 값
     * @return bool 등록 유무
     */
    function isContentsUser(string contentsHash) private view returns(bool) {
        return msg.sender == contentsStorage.getAddressValue(contentsHash);
    }
    
    /**
     * @dev 콘텐츠의 유저 주소를 반환
     * @param contentsHash 유저 주소를 조회하고자 하는 콘텐츠의 유일 값
     * @return writer 콘텐츠를 업로드한 유저의 주소
     */
    function getWriter(string contentsHash) 
        external 
        view 
        validString(contentsHash)
        returns(address writer) 
    {
        return contentsStorage.getAddressValue(contentsHash);
    }

    /**
     * @dev 콘텐츠의 정보 조회
     * @param contentsHash 콘텐츠의 유일 값
     * @return rawData 콘텐츠 정보
     */
    function getContentsRawData(string contentsHash)
        external
        view
        validString(contentsHash)
        returns(string rawData)
    {
        return contentsStorage.getStringValue(contentsHash);
    }

    /**
     * @dev 콘텐츠와 유저의 연결성 확인
     * @param contentsHash 확인하고자 하는 콘텐츠 유일 값
     * @return userHash 유저의 유일 값
     */
    function getUserHash(string contentsHash) 
        external 
        view 
        validString(contentsHash)
        returns(string userHash) 
    {
        return relationStorage.getStringValue(contentsHash);
    }

    /**
     * @dev 저장소 주소 변경
     * @param cStorage Contents 정보가 저장되는 주소
     * @param rStorage Contents와 유저가 매핑되는 저장소 주소
     */
    function changeStorage(address cStorage, address rStorage) 
        validAddress(cStorage)
        validAddress(rStorage)
        external 
        onlyOwner
    {
        contentsStorage = IStorage(cStorage);
        relationStorage = IStorage(rStorage);
    }

    /**
     * @dev 참조하는 Manager 주소 변경
     * @param aManager 유저 정보를 관리하는 주소
     */
    function changeManager(address aManager) 
        validAddress(aManager)
        external 
        onlyOwner
    {
        accountManager = IAccountsManager(aManager);
    }
}