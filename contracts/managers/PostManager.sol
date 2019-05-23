pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";
import "../interfaces/IProjectManager.sol";
import "../interfaces/IPostManager.sol";
import "../interfaces/IUpdateAddress.sol";
import "../interfaces/IStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/StringLib.sol";

contract PostManager is Ownable, ValidValue, IPostManager, IUpdateAddress {
    using StringLib for string;

    string private constant STORAGE_NAME = "ProjectStorage";
    string private constant RELATION_NAME = "RelationStorage";
    string private constant ACCOUNT_NAME = "AccountsManager";
    string private constant PROJECT_NAME = "ProjectManager";
    string private constant CREATE_TAG = "createPost";
    string private constant UPDATE_TAG = "updatePost";
    string private constant DELETE_TAG = "deletePost";
    string private constant MOVE_TAG = "movePost";

    IPictionNetwork private pictionNetwork;
    IStorage private projectStorage;
    IStorage private relationStorage;

    IAccountsManager private accountManager;
    IProjectManager private projectManager;

    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);

        projectStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        relationStorage = IStorage(pictionNetwork.getAddress(RELATION_NAME));

        accountManager = IAccountsManager(pictionNetwork.getAddress(ACCOUNT_NAME));
        projectManager = IProjectManager(pictionNetwork.getAddress(PROJECT_NAME));
    }

    /**
     * @dev Post 생성
     * @param userHash Post 생성하는 유저의 유일 값
     * @param projectHash Post 생성하는 프로젝트의 유일 값
     * @param postHash 생성되는 Post의 유일 값
     * @param rawData Post 정보
     */
    function createPost(
        string userHash, 
        string projectHash, 
        string postHash, 
        string rawData
    ) 
        external
        validString(userHash)
        validString(projectHash)
        validString(postHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "PostManager createPost 0");
        require(isProjectUser(projectHash), "PostManager createPost 1");

        require(projectStorage.getAddressValue(postHash) == address(0) ,"PostManager createPost 2");
        require(projectStorage.getStringValue(postHash).isEmptyString(), "PostManager createPost 3");

        projectStorage.setAddressValue(postHash, msg.sender, CREATE_TAG);
        projectStorage.setStringValue(postHash, rawData, CREATE_TAG);

        relationStorage.setStringValue(postHash, projectHash, CREATE_TAG);
    }

    /**
     * @dev Post 수정
     * @param userHash Post 수정하는 유저의 유일 값
     * @param projectHash Post 수정하는 프로젝트의 유일 값
     * @param postHash 수정되는 Post의 유일 값
     * @param rawData Post 정보
     */
    function updatePost(
        string userHash, 
        string projectHash, 
        string postHash, 
        string rawData
    ) 
        external
        validString(userHash)
        validString(projectHash)
        validString(postHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "PostManager updatePost 0");
        require(isProjectUser(projectHash), "PostManager updatePost 1");

        require(projectStorage.getAddressValue(postHash) == msg.sender, "PostManager updatePost 2");
        require(!projectStorage.getStringValue(postHash).isEmptyString(), "PostManager updatePost 3");
        
        projectStorage.setStringValue(postHash, rawData, UPDATE_TAG);
    }

    /**
     * @dev Post 삭제
     * @param userHash Post 생성한 유저의 유일 값
     * @param projectHash Post 생성한 프로젝트의 유일 값
     * @param postHash 생성되는 Post의 유일 값
     */
    function deletePost(
        string userHash, 
        string projectHash, 
        string postHash
    )
        external
        validString(userHash)
        validString(projectHash)
        validString(postHash)
    {
        require(isPictionUser(userHash) || isOwner(), "PostManager deletePost 0");
        require(isProjectUser(projectHash) || isOwner(), "PostManager deletePost 1");

        require(projectStorage.getAddressValue(postHash) == msg.sender || isOwner(), "PostManager deletePost 2");
        require(!projectStorage.getStringValue(postHash).isEmptyString(), "PostManager deletePost 3");

        projectStorage.deleteAddressValue(postHash, DELETE_TAG);
        projectStorage.deleteStringValue(postHash, DELETE_TAG);

        relationStorage.deleteStringValue(postHash, DELETE_TAG);
    }

    /**
     * @dev Post 이동
     * @param userHash Post 생성하는 유저의 유일 값
     * @param beforeProjectHash Post가 있는 프로젝트의 유일 값
     * @param afterProjectHash Post를 이동시키고자 하는 프로젝트의 유일 값
     * @param postHash 이동시키고자 하는 Post의 유일 값
     */
    function movePost(
        string userHash, 
        string beforeProjectHash, 
        string afterProjectHash, 
        string postHash
    ) 
        external 
        validString(userHash)
        validString(beforeProjectHash)
        validString(afterProjectHash)
        validString(postHash)
    {
        require(isPictionUser(userHash), "PostManager movePost 0");
        require(isProjectUser(beforeProjectHash), "PostManager movePost 1");
        require(isProjectUser(afterProjectHash), "PostManager movePost 2");

        require(projectStorage.getAddressValue(postHash) == msg.sender,"PostManager movePost 3");
        require(!projectStorage.getStringValue(postHash).isEmptyString(),"PostManager movePost 4");

        require(!relationStorage.getStringValue(postHash).isEmptyString(),"PostManager movePost 5");

        relationStorage.deleteStringValue(postHash, MOVE_TAG);
        relationStorage.setStringValue(postHash, afterProjectHash, MOVE_TAG);
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
     * @dev 프로젝트를 등록한 유저인지 확인
     * @param projectHash 확인할 프로젝트의 유일 값
     * @return bool 등록 유무
     */
    function isProjectUser(string projectHash) private view returns(bool) {
        return msg.sender == projectManager.getWriter(projectHash);
    }

    /**
     * @dev Post 유저 주소를 반환
     * @param postHash 유저 주소를 조회하고자 하는 Post의 유일 값
     * @return writer Post를 업로드한 유저의 주소
     */
    function getPostWriter(string postHash) external view validString(postHash) returns(address writer) {
        return projectStorage.getAddressValue(postHash);
    }

    /**
     * @dev Post의 정보 조회
     * @param postHash Post의 유일 값
     * @return rawData 프로젝트 정보
     */
    function getPostRawData(string postHash) external view validString(postHash) returns(string memory rawData) {
        return projectStorage.getStringValue(postHash);
    }

    /**
     * @dev Post와 프로젝트의 연결성 확인
     * @param postHash 확인하고자 하는 Post 유일 값
     * @return projectHash 프로젝트의 유일 값
     */
    function getProjectHash(string postHash) external view validString(postHash) returns(string projectHash) {
        return relationStorage.getStringValue(postHash);
    }

    /**
     * @dev 저장소 업데이트
     */
    function updateAddress() external {
        require(msg.sender == address(pictionNetwork), "PostManager updateAddress 0");

        address pStorage = pictionNetwork.getAddress(STORAGE_NAME);
        emit UpdateAddress(address(projectStorage), pStorage);
        projectStorage = IStorage(pStorage);

        address rStorage = pictionNetwork.getAddress(RELATION_NAME);
        emit UpdateAddress(address(relationStorage), rStorage);
        relationStorage = IStorage(rStorage);

        address aManager = pictionNetwork.getAddress(ACCOUNT_NAME);
        emit UpdateAddress(address(accountManager), aManager);
        accountManager = IAccountsManager(aManager);

        address pManager = pictionNetwork.getAddress(PROJECT_NAME);
        emit UpdateAddress(address(projectManager), pManager);
        projectManager = IProjectManager(pManager);
    }
}