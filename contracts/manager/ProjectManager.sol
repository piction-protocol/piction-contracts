pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "../utils/ExtendsOwnable.sol";
import "../interfaces/IAccountManager.sol";
import "../interfaces/IProjectmanager.sol";
import "../interfaces/IPictionNetwork.sol";

/**
 * @title ProjectManager
 * @dev 작가가 생성한 Project 관리
 */
contract ProjectManager is ExtendsOwnable, ValidValue, IProjectManager {

    struct Project {
        bool isRegistered;
        address owner;
        string uri;
    }

    mapping (string => Project) projects;
    mapping (string => bool) isRegisteredUri;

    IPictionNetwork private pictionNetwork;

    string private constant ACCOUNTMANAGER = "AccountManager";

    constructor(address pictionNetworkAddress) public validAddress(pictionNetworkAddress) {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
    }

    /**
      * @dev 프로젝트 생성
      * @param hash unique hash
      * @param uri unique uri
      */
    function create(string hash, string uri) external validString(hash) validString(uri) {
        createProject(msg.sender, hash, uri);
        emit CreateProject(msg.sender, hash, uri);
    }

    /**
      * @dev 기존에 생성 된 프로젝트 migration - Piction 계정 실행
      * @param creator creator public address
      * @param hash unique hash
      * @param uri unique uri
      */
    function migration(address creator, string hash, string uri) external onlyOwner validString(hash) validString(uri) {
        createProject(creator, hash, uri);
        emit Migration(msg.sender, creator, hash, uri);
    }

    /**
      * @dev 프로젝트 생성 내부 함수
      * @param creator 사용자 public address
      * @param hash unique hash
      * @param uri unique uri
      */
    function createProject(address creator, string hash, string uri) private {
        require(IAccountManager(pictionNetwork.getAddress(ACCOUNTMANAGER)).accountValidation(creator), "ProjectManager createProject 0");
        require(!projects[hash].isRegistered, "ProjectManager createProject 1");
        require(!isRegisteredUri[uri], "ProjectManager createProject 2");

        projects[hash].isRegistered = true;
        projects[hash].owner = creator;
        projects[hash].uri = uri;

        isRegisteredUri[uri] = true;
    }

    /**
      * @dev 프로젝트 등록 여부 확인
      * @param str hash
      * @return hash 등록 결과
      */
    function hashValidation(string str) external view returns(bool) {
        return projects[str].isRegistered;
    }

    /**
      * @dev 프로젝트 고유 값 확인
      * @param uri uri
      * @return 고유 정보 중복 결과
      */
    function uriValidation(string uri) external view returns(bool) {
        return isRegisteredUri[uri];
    }

    /**
      * @dev creator public address 확인
      * @param hash unique hash
      * @return creator public address
      */
    function getProjectOwner(string hash) external view returns(address) {
        return projects[hash].owner;
    }

    /**
      * @dev 프로젝트 상세 정보 확인
      * @param hash unique hash
      * @return 프로젝트 상세 정보
      */
    function getProject(string hash) external view returns(bool, address, string) {
        return (projects[hash].isRegistered, projects[hash].owner, projects[hash].uri);
    }

    event CreateProject(address indexed sender, string hash, string uri);
    event Migration(address indexed sender, address indexed creator, string hash, string uri);
}