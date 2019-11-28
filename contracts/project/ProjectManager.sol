pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "../utils/ExtendsOwnable.sol";
import "../interfaces/IValidation.sol";
import "../interfaces/IPictionNetwork.sol";

/**
 * @title ProjectManager
 * @dev 작가가 생성한 Project 관리
 */
contract ProjectManager is ExtendsOwnable, ValidValue {

    struct project {
        bool isRegistered;
        address wallet;
        string uri;
    }

    mapping (string => project) projects;
    mapping (string => bool) isDuplicateString;

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
        require(IValidation(pictionNetwork.getAddress(ACCOUNTMANAGER)).accountValidation(msg.sender), "ProjectManager deploy 0");
        require(!projects[hash].isRegistered, "ProjectManager deploy 1");
        require(!isDuplicateString[uri], "ProjectManager deploy 2");

        projects[hash].isRegistered = true;
        projects[hash].wallet = msg.sender;
        projects[hash].uri = uri;

        isDuplicateString[uri] = true;

        emit Deploy(msg.sender, hash, uri);
    }

    /**
      * @dev 기존에 생성 된 프로젝트 migration - Piction 계정 실행
      * @param user creator public address
      * @param hash unique hash
      * @param uri unique uri
      */
    function migration(address user, string hash, string uri) external onlyOwner validString(hash) validString(uri) {
        require(IValidation(pictionNetwork.getAddress(ACCOUNTMANAGER)).accountValidation(user), "ProjectManager migration 0");
        require(!projects[hash].isRegistered, "ProjectManager migration 1");
        require(!isDuplicateString[uri], "ProjectManager migration 2");

        projects[hash].isRegistered = true;
        projects[hash].wallet = user;
        projects[hash].uri = uri;

        isDuplicateString[uri] = true;

        emit Migration(msg.sender, user, hash, uri);
    }

    /**
      * @dev 프로젝트 고유 값 확인
      * @param str hash or uri
      * @return 고유 정보 중복 여부
      */
    function stringValidation(string str) external view returns(bool) {
        return isDuplicateString[str];
    }

    /**
      * @dev creator public address 확인
      * @param hash unique hash
      * @return creator public address
      */
    function getProjectOwner(string hash) external view returns(address) {
        return projects[hash].wallet;
    }

    /**
      * @dev 프로젝트 상세 정보 확인
      * @param hash unique hash
      * @return 프로젝트 상세 정보
      */
    function getProject(string hash) external view returns(bool, address, string) {
        return (projects[hash].isRegistered, projects[hash].wallet, projects[hash].uri);
    }

    event Deploy(address indexed sender, string hash, string uri);
    event Migration(address indexed sender, address indexed user, string hash, string uri);
}