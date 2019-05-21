pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountsManager.sol";
import "../interfaces/IProjectManager.sol";
import "../interfaces/IUpdateAddress.sol";
import "../interfaces/IStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/StringLib.sol";

contract ProjectManager is Ownable, ValidValue, IProjectManager, IUpdateAddress {
    using StringLib for string;

    string private constant STORAGE_NAME = "ProjectStorage";
    string private constant RELATION_NAME = "RelationStorage";
    string private constant ACCOUNT_NAME = "AccountsManager";
    string private constant CREATE_TAG = "createProject";
    string private constant UPDATE_TAG = "updateProject";
    string private constant DELETE_TAG = "deleteProject";

    IPictionNetwork private pictionNetwork;

    IStorage private projectStorage;
    IStorage private relationStorage;

    IAccountsManager private accountManager;


    constructor(address piction) public validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);

        projectStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        relationStorage = IStorage(pictionNetwork.getAddress(RELATION_NAME));
        
        accountManager = IAccountsManager(pictionNetwork.getAddress(ACCOUNT_NAME));
    }

    /**
     * @dev 프로젝트 생성 
     * @param userHash 생성하는 유저의 유일 값
     * @param projectHash 생성하는 프로젝트의 유일 값
     * @param rawData 생성되는 프로젝트의 데이터
     */
    function createProject(
        string userHash, 
        string projectHash, 
        string rawData
    ) 
        external
        validString(userHash) 
        validString(projectHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "ProjectManager createProject 0");

        require(projectStorage.getAddressValue(projectHash) == address(0), "ProjectManager createProject 1");
        require(projectStorage.getStringValue(projectHash).isEmptyString(), "ProjectManager createProject 2");

        projectStorage.setAddressValue(projectHash, msg.sender, CREATE_TAG);
        projectStorage.setStringValue(projectHash, rawData, CREATE_TAG);

        relationStorage.setStringValue(projectHash, userHash, CREATE_TAG);

        //if necessary, deploy contract.
    }

    /**
     * @dev 프로젝트의 데이터를 업데이트
     * @param userHash 업데이트하는 유저의 고유 값
     * @param projectHash 업데이트하는 프로젝트의 고유 값
     * @param rawData 엡데이트 데이터
     */
    function updateProject(
        string userHash, 
        string projectHash, 
        string rawData
    ) 
        external
        validString(userHash) 
        validString(projectHash)
        validString(rawData)
    {
        require(isPictionUser(userHash), "ProjectManager updateProject 0");

        require(isProjectUser(projectHash) ,"ProjectManager updateProject 1");
        require(!projectStorage.getStringValue(projectHash).isEmptyString(),"ProjectManager updateProject 2");

        projectStorage.setStringValue(projectHash, rawData, UPDATE_TAG);
    }

    /**
     * @dev Project 삭제
     * @param userHash 삭제를 요청하는 유저의 유일한 값
     * @param projectHash 삭제하고자 하는 프로젝트의 유일한 값
     */
    function deleteProject(string userHash, string projectHash) external validString(userHash) validString(projectHash) {
        require(isPictionUser(userHash) || isOwner(), "ProjectManager deleteProject 0");

        require(isProjectUser(projectHash) || isOwner() ,"ProjectManager deleteProject 1");
        require(!projectStorage.getStringValue(projectHash).isEmptyString(),"ProjectManager deleteProject 2");

        projectStorage.deleteAddressValue(projectHash, DELETE_TAG);
        projectStorage.deleteStringValue(projectHash, DELETE_TAG);

        relationStorage.deleteStringValue(projectHash, DELETE_TAG);
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
        return msg.sender == projectStorage.getAddressValue(projectHash);
    }
    
    /**
     * @dev 프로젝트의 유저 주소를 반환
     * @param projectHash 유저 주소를 조회하고자 하는 프로젝트의 유일 값
     * @return writer 프로젝트를 업로드한 유저의 주소
     */
    function getWriter(string projectHash) external view validString(projectHash) returns(address writer) {
        return projectStorage.getAddressValue(projectHash);
    }

    /**
     * @dev 프로젝트의 정보 조회
     * @param projectHash 프로젝트의 유일 값
     * @return rawData 프로젝트 정보
     */
    function getProjectRawData(string projectHash) external view validString(projectHash) returns(string rawData) {
        return projectStorage.getStringValue(projectHash);
    }

    /**
     * @dev 프로젝트와 유저의 연결성 확인
     * @param projectHash 확인하고자 하는 프로젝트 유일 값
     * @return userHash 유저의 유일 값
     */
    function getUserHash(string projectHash) external view validString(projectHash) returns(string userHash) {
        return relationStorage.getStringValue(projectHash);
    }

    /**
     * @dev 저장소 업데이트
     */
    function updateAddress() external {
        require(msg.sender == address(pictionNetwork), "ProjectManager updateAddress 0");

        address cStorage = pictionNetwork.getAddress(STORAGE_NAME);
        emit UpdateAddress(address(projectStorage), cStorage);
        projectStorage = IStorage(cStorage);

        address rStorage = pictionNetwork.getAddress(RELATION_NAME);
        emit UpdateAddress(address(relationStorage), rStorage);
        relationStorage = IStorage(rStorage);

        address aManager = pictionNetwork.getAddress(ACCOUNT_NAME);
        emit UpdateAddress(address(accountManager), aManager);
        accountManager = IAccountsManager(aManager);
    }
}