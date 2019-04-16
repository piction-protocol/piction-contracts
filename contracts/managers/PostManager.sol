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

    constructor(address piction) public validAddress(piction) {
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
        require(iStorage.getStringValue(postHash).isEmptyString(),"createPost : Already rawdata.");

        iStorage.setAddressValue(postHash, msg.sender, CREATE_TAG);
        iStorage.setStringValue(postHash, rawData, CREATE_TAG);

        iStorage = IStorage(pictionNetwork.getAddress(RELATION_NAME));
        iStorage.setStringValue(postHash, contentsHash, CREATE_TAG);
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
        require(!iStorage.getStringValue(postHash).isEmptyString(),"updatePost : rawdata Empty");
        
        iStorage.setStringValue(postHash, rawData, UPDATE_TAG);
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

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        require(iStorage.getAddressValue(postHash) == msg.sender || isOwner() ,"deletePost : Not Match User.");
        require(!iStorage.getStringValue(postHash).isEmptyString(),"deletePost : rawdata Empty");

        iStorage.deleteAddressValue(postHash, DELETE_TAG);
        iStorage.deleteStringValue(postHash, DELETE_TAG);

        iStorage = IStorage(pictionNetwork.getAddress(RELATION_NAME));
        iStorage.deleteStringValue(postHash, DELETE_TAG);
    }

    /**
     * @dev Post 이동
     * @param userHash Post 생성하는 유저의 유일 값
     * @param beforContentsHash Post가 있는 콘텐츠의 유일 값
     * @param afterContentsHash Post를 이동시키고자 하는 콘텐츠의 유일 값
     * @param postHash 이동시키고자 하는 Post의 유일 값
     */
    function movePost(string userHash, string beforContentsHash, string afterContentsHash, string postHash) 
        external 
        validString(userHash)
        validString(beforContentsHash)
        validString(afterContentsHash)
        validString(postHash)
    {
        require(isPictionUser(userHash), "movePost : Not Match Sender");
        require(isContentsUser(beforContentsHash), "movePost : Contents Not Match Sender");
        require(isContentsUser(afterContentsHash), "movePost : Contents Not Match Sender");

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        require(iStorage.getAddressValue(postHash) == msg.sender,"movePost : Not Match User.");
        require(!iStorage.getStringValue(postHash).isEmptyString(),"movePost : rawdata Empty");

        iStorage = IStorage(pictionNetwork.getAddress(RELATION_NAME));
        require(!iStorage.getStringValue(postHash).isEmptyString(),"movePost : contentsHash Empty");

        iStorage.deleteStringValue(postHash, MOVE_TAG);
        iStorage.setStringValue(postHash, afterContentsHash, MOVE_TAG);
    }

    /**
     * @dev 픽션에 등록된 유저인지 확인
     * @param userHash 확인할 유저의 유일 값
     * @return bool 등록 유저유무
     */
    function isPictionUser(string userHash) private view returns(bool) {
        IAccountsManager accountManager = IAccountsManager(pictionNetwork.getAddress(ACCOUNT_NAME));
        return msg.sender == accountManager.getUserAddress(userHash);
    }

    /**
     * @dev 콘텐츠를 등록한 유저인지 확인
     * @param contentsHash 확인할 콘텐츠의 유일 값
     * @return bool 등록 유무
     */
    function isContentsUser(string contentsHash) private view returns(bool) {
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
        view
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
        view
        validString(postHash)
        returns(string memory rawData)
    {
        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        rawData = iStorage.getStringValue(postHash);
        require(!rawData.isEmptyString(),"getPostRawData : RawData Empty.");
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
        IStorage iStorage = IStorage(pictionNetwork.getAddress(RELATION_NAME));

        contentsHash = iStorage.getStringValue(postHash);
        require(!contentsHash.isEmptyString(),"getContentsHash : ContentsHash Empty.");
    }
}