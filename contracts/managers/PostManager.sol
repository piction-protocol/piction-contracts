pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";
import "../interfaces/IContentsManager.sol";
import "../interfaces/IPostManager.sol";
import "../interfaces/IStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";
import "../utils/StringLib.sol";

contract PostManager is Ownable, ValidValue, IPostManager {

    string public constant STORAGE_NAME = "ContentsStorage";
    string public constant ACCOUNT_NAME = "AccountsManager";
    string public constant CONTENTS_NAME = "ContentsManager";
    string public constant CREATE_TAG = "createPost";
    string public constant UPDATE_TAG = "updatePost";
    string public constant DELETE_TAG = "deletePost";

    IPictionNetwork pictionNetwork;

    constructor(address piction) {
        pictionNetwork = IPictionNetwork(piction);
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

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        require(iStorage.getAddressValue(postHash) == address(0) ,"createPost : Already address.");
        require(StringLib.isEmptyString(iStorage.getStringValue(postHash)),"createPost : Already rawdata.");

        iStorage.setAddressValue(postHash, msg.sender, CREATE_TAG);
        iStorage.setStringValue(postHash, rawData, CREATE_TAG);

        emit CreatePost(msg.sender, userHash, contentsHash, postHash);
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

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        require(iStorage.getAddressValue(postHash) == msg.sender ,"updatePost : Not Match User.");
        require(!StringLib.isEmptyString(iStorage.getStringValue(postHash)),"updatePost : rawdata Empty");
        
        iStorage.setStringValue(postHash, rawData, UPDATE_TAG);

        emit UpdatePost(msg.sender, userHash, contentsHash, postHash);
    }

    /**
     * @dev Post 생성
     * @param userHash Post 생성하는 유저의 유일 값
     * @param contentsHash Post 생성하는 콘텐츠의 유일 값
     * @param postHash 생성되는 Post의 유일 값
     */
    function removePost(string userHash, string contentsHash, string postHash)
        external
        validString(userHash)
        validString(contentsHash)
        validString(postHash)
    {
        require(isPictionUser(userHash) || isOwner(), "deletePost : Not Match Sender");
        require(isContentsUser(contentsHash) || isOwner(), "deletePost : Contents Not Match Sender");

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        require(iStorage.getAddressValue(postHash) == msg.sender || isOwner() ,"deletePost : Not Match User.");
        require(!StringLib.isEmptyString(iStorage.getStringValue(postHash)),"deletePost : rawdata Empty");

        iStorage.deleteAddressValue(contentsHash, DELETE_TAG);
        iStorage.deleteStringValue(contentsHash, DELETE_TAG);

        emit RemovePost(msg.sender, userHash, contentsHash, postHash);
    }

    //TODO MovePost 다른 콘텐츠로 Post 이동

    /**
     * @dev 픽션에 등록된 유저인지 확인
     * @param userHash 확인할 유저의 유일 값
     * @return bool 등록 유저유무
     */
    function isPictionUser(string userHash) private returns(bool) {
        IAccountsManager accountManager = IAccountsManager(pictionNetwork.getAddress(ACCOUNT_NAME));
        return msg.sender == accountManager.getUserAddress(userHash);
    }

    /**
     * @dev 콘텐츠를 등록한 유저인지 확인
     * @param contentsHash 확인할 콘텐츠의 유일 값
     * @return bool 등록 유무
     */
    function isContentsUser(string contentsHash) private returns(bool) {
        IContentsManager contentsManager = IContentsManager(pictionNetwork.getAddress(CONTENTS_NAME));
        return msg.sender == contentsManager.getWriter(contentsHash);
    }

    /**
     * @dev Post 유저 주소를 반환
     * @param postHash 유저 주소를 조회하고자 하는 Post의 유일 값
     * @return writer Post를 업로드한 유저의 주소
     */
    function getPostWriter(string postHash) 
        external  
        validString(postHash)
        returns(address writer) 
    {
        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        writer = iStorage.getAddressValue(postHash);
        require(writer != address(0), "getPostWriter : Address 0");
    }

    /**
     * @dev Post의 정보 조회
     * @param postHash Post의 유일 값
     * @return rawData 콘텐츠 정보
     */
    function getPostRawData(string postHash)
        external
        validString(postHash)
        returns(string rawData)
    {
        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        rawData = iStorage.getStringValue(postHash);
        require(!StringLib.isEmptyString(rawData),"getPostRawData : RawData Empty.");
    }
}