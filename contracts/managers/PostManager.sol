pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";
import "../interfaces/IContentsManager.sol";
import "../interfaces/IPostManager.sol";
import "../interfaces/IStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/StringLib.sol";

contract PostManager is Ownable, ValidValue, IPostManager {
    using StringLib for string;

    string public constant STORAGE_NAME = "ContentsStorage";
    string public constant RELATION_NAME = "RelationStorage";
    string public constant ACCOUNT_NAME = "AccountsManager";
    string public constant CONTENTS_NAME = "ContentsManager";
    string public constant CREATE_TAG = "createPost";
    string public constant UPDATE_TAG = "updatePost";
    string public constant DELETE_TAG = "deletePost";
    string public constant MOVE_TAG = "movePost";

    IPictionNetwork pictionNetwork;
    IStorage private contentsStorage;
    IStorage private relationStorage;

    IAccountsManager private accountManager;
    IContentsManager private contentsManager;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);

        address contents = pictionNetwork.getAddress(STORAGE_NAME);
        require(contents != address(0), "ContentsManager deploy failed: Check contents storage address");

        address relation = pictionNetwork.getAddress(RELATION_NAME);
        require(relation != address(0), "ContentsManager deploy failed: Check relation storage address");

        address aManager = pictionNetwork.getAddress(ACCOUNT_NAME);
        require(aManager != address(0), "ContentsManager deploy failed: Check accounts manager address");

        address cManager = pictionNetwork.getAddress(CONTENTS_NAME);
        require(cManager != address(0), "ContentsManager deploy failed: Check contents manager address");

        contentsStorage = IStorage(contents);
        relationStorage = IStorage(relation);

        accountManager = IAccountsManager(aManager);
        contentsManager = IContentsManager(cManager);
    }

    /**
     * @dev Post 생성
     * @param userHash Post 생성하는 유저의 유일 값
     * @param contentsHash Post 생성하는 콘텐츠의 유일 값
     * @param postHash 생성되는 Post의 유일 값
     * @param rawData Post 정보
     */
    function createPost(string userHash, string contentsHash, string postHash, string rawData) 
        external
        validString(userHash)
        validString(contentsHash)
        validString(postHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "createPost : Not Match Sender");
        require(isContentsUser(contentsHash), "createPost : Contents Not Match Sender");

        require(contentsStorage.getAddressValue(postHash) == address(0) ,"createPost : Already address.");
        require(contentsStorage.getStringValue(postHash).isEmptyString(),"createPost : Already rawdata.");

        contentsStorage.setAddressValue(postHash, msg.sender, CREATE_TAG);
        contentsStorage.setStringValue(postHash, rawData, CREATE_TAG);

        relationStorage.setStringValue(postHash, contentsHash, CREATE_TAG);
    }

    /**
     * @dev Post 수정
     * @param userHash Post 수정하는 유저의 유일 값
     * @param contentsHash Post 수정하는 콘텐츠의 유일 값
     * @param postHash 수정되는 Post의 유일 값
     * @param rawData Post 정보
     */
    function updatePost(string userHash, string contentsHash, string postHash, string rawData) 
        external
        validString(userHash)
        validString(contentsHash)
        validString(postHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "updatePost : Not Match Sender");
        require(isContentsUser(contentsHash), "updatePost : Contents Not Match Sender");

        require(contentsStorage.getAddressValue(postHash) == msg.sender ,"updatePost : Not Match User.");
        require(!contentsStorage.getStringValue(postHash).isEmptyString(),"updatePost : rawdata Empty");
        
        contentsStorage.setStringValue(postHash, rawData, UPDATE_TAG);
    }

    /**
     * @dev Post 삭제
     * @param userHash Post 생성한 유저의 유일 값
     * @param contentsHash Post 생성한 콘텐츠의 유일 값
     * @param postHash 생성되는 Post의 유일 값
     */
    function deletePost(string userHash, string contentsHash, string postHash)
        external
        validString(userHash)
        validString(contentsHash)
        validString(postHash)
    {
        require(isPictionUser(userHash) || isOwner(), "deletePost : Not Match Sender");
        require(isContentsUser(contentsHash) || isOwner(), "deletePost : Contents Not Match Sender");

        require(contentsStorage.getAddressValue(postHash) == msg.sender || isOwner() ,"deletePost : Not Match User.");
        require(!contentsStorage.getStringValue(postHash).isEmptyString(),"deletePost : rawdata Empty");

        contentsStorage.deleteAddressValue(postHash, DELETE_TAG);
        contentsStorage.deleteStringValue(postHash, DELETE_TAG);

        relationStorage.deleteStringValue(postHash, DELETE_TAG);
    }

    /**
     * @dev Post 이동
     * @param userHash Post 생성하는 유저의 유일 값
     * @param beforeContentsHash Post가 있는 콘텐츠의 유일 값
     * @param afterContentsHash Post를 이동시키고자 하는 콘텐츠의 유일 값
     * @param postHash 이동시키고자 하는 Post의 유일 값
     */
    function movePost(string userHash, string beforeContentsHash, string afterContentsHash, string postHash) 
        external 
        validString(userHash)
        validString(beforeContentsHash)
        validString(afterContentsHash)
        validString(postHash)
    {
        require(isPictionUser(userHash), "movePost : Not Match Sender");
        require(isContentsUser(beforeContentsHash), "movePost : Contents Not Match Sender");
        require(isContentsUser(afterContentsHash), "movePost : Contents Not Match Sender");

        require(contentsStorage.getAddressValue(postHash) == msg.sender,"movePost : Not Match User.");
        require(!contentsStorage.getStringValue(postHash).isEmptyString(),"movePost : rawdata Empty");

        require(!relationStorage.getStringValue(postHash).isEmptyString(),"movePost : contentsHash Empty");

        relationStorage.deleteStringValue(postHash, MOVE_TAG);
        relationStorage.setStringValue(postHash, afterContentsHash, MOVE_TAG);
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
        return msg.sender == contentsManager.getWriter(contentsHash);
    }

    /**
     * @dev Post 유저 주소를 반환
     * @param postHash 유저 주소를 조회하고자 하는 Post의 유일 값
     * @return writer Post를 업로드한 유저의 주소
     */
    function getPostWriter(string postHash) 
        external 
        view
        validString(postHash)
        returns(address writer) 
    {
        return contentsStorage.getAddressValue(postHash);
    }

    /**
     * @dev Post의 정보 조회
     * @param postHash Post의 유일 값
     * @return rawData 콘텐츠 정보
     */
    function getPostRawData(string postHash)
        external 
        view
        validString(postHash)
        returns(string memory rawData)
    {
        return contentsStorage.getStringValue(postHash);
    }

    /**
     * @dev Post와 콘텐츠의 연결성 확인
     * @param postHash 확인하고자 하는 Post 유일 값
     * @return contentsHash 콘텐츠의 유일 값
     */
    function getContentsHash(string postHash) 
        external
        view 
        validString(postHash)
        returns(string contentsHash) 
    {
        return relationStorage.getStringValue(postHash);
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
     * @dev 참조하는 메니저 주소 변경
     * @param aManager 유저 정보가 관리되는 주소
     * @param cManager Contents 정보가 괸리되는 주소
     */
    function changeManager(address aManager, address cManager) 
        validAddress(aManager)
        validAddress(cManager)
        external 
        onlyOwner
    {
        accountManager = IAccountsManager(aManager);
        contentsManager = IContentsManager(cManager);
    }
}