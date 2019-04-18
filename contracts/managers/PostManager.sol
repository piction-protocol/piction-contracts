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
        require(contents != address(0), "PostManager constructor 0");

        address relation = pictionNetwork.getAddress(RELATION_NAME);
        require(relation != address(0), "PostManager constructor 1");

        address aManager = pictionNetwork.getAddress(ACCOUNT_NAME);
        require(aManager != address(0), "PostManager constructor 2");

        address cManager = pictionNetwork.getAddress(CONTENTS_NAME);
        require(cManager != address(0), "PostManager constructor 3");

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
        require(isPictionUser(userHash), "PostManager createPost 0");
        require(isContentsUser(contentsHash), "PostManager createPost 1");

        require(contentsStorage.getAddressValue(postHash) == address(0) ,"PostManager createPost 2");
        require(contentsStorage.getStringValue(postHash).isEmptyString(), "PostManager createPost 3");

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
        require(isPictionUser(userHash), "PostManager updatePost 0");
        require(isContentsUser(contentsHash), "PostManager updatePost 1");

        require(contentsStorage.getAddressValue(postHash) == msg.sender, "PostManager updatePost 2");
        require(!contentsStorage.getStringValue(postHash).isEmptyString(), "PostManager updatePost 3");
        
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
        require(isPictionUser(userHash) || isOwner(), "PostManager deletePost 0");
        require(isContentsUser(contentsHash) || isOwner(), "PostManager deletePost 1");

        require(contentsStorage.getAddressValue(postHash) == msg.sender || isOwner(), "PostManager deletePost 2");
        require(!contentsStorage.getStringValue(postHash).isEmptyString(), "PostManager deletePost 3");

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
        require(isPictionUser(userHash), "PostManager movePost 0");
        require(isContentsUser(beforeContentsHash), "PostManager movePost 1");
        require(isContentsUser(afterContentsHash), "PostManager movePost 2");

        require(contentsStorage.getAddressValue(postHash) == msg.sender,"PostManager movePost 3");
        require(!contentsStorage.getStringValue(postHash).isEmptyString(),"PostManager movePost 4");

        require(!relationStorage.getStringValue(postHash).isEmptyString(),"PostManager movePost 5");

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
     * @dev 저장소 업데이트
     */
    function updateAddress() 
        onlyOwner 
        external
    {
        address cStorage = pictionNetwork.getAddress(STORAGE_NAME);
        require(cStorage != address(0), "PostManager updateAddress 0");
        if (address(contentsStorage) != cStorage) {
            emit UpdateAddress(address(contentsStorage), cStorage);
            contentsStorage = IStorage(cStorage);
        }

        address rStorage = pictionNetwork.getAddress(RELATION_NAME);
        require(rStorage != address(0), "PostManager updateAddress 1");
        if (address(relationStorage) != rStorage) {
            emit UpdateAddress(address(relationStorage), rStorage);
            relationStorage = IStorage(rStorage);
        }

        address aManager = pictionNetwork.getAddress(ACCOUNT_NAME);
        require(aManager != address(0), "PostManager updateAddress 2");
        if (address(accountManager) != aManager) {
            emit UpdateAddress(address(accountManager), aManager);
            accountManager = IAccountsManager(aManager);
        }

        address cManager = pictionNetwork.getAddress(CONTENTS_NAME);
        require(cManager != address(0), "PostManager updateAddress 3");
        if (address(contentsManager) != cManager) {
            emit UpdateAddress(address(contentsManager), cManager);
            contentsManager = IContentsManager(cManager);
        }
    }
}