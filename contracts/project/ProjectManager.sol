pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "./Project.sol";

contract ProjectManager is ValidValue {

    mapping(string => bool) private uriChecker;

    /**
     * @dev 프로젝트 생성 
     * @param uri 프로젝트 고유한 uri 정보
     * @param title 프로젝트 이름
     * @param subscriptionPrice 프로젝트 구독 가격
     */
    function createProject(
        string uri, 
        string title, 
        uint256 subscriptionPrice
    ) 
        external
        validString(uri) 
        validString(title)
    {
        require(!uriChecker[uri], "ProjectManager createProject 0");

        address project = new Project(uri, title, subscriptionPrice, msg.sender);
        uriChecker[uri] = true;

        emit DeployProject(msg.sender, project, now * 1000);
    }

    /**
     * @dev 프로젝트 uri 중복 확인
     * @param uri 프로젝트 고유한 uri 정보
     * @return uri 중복 여부
     */
    function isExistedUri(string uri) external view returns(bool) {
        return uriChecker[uri];
    }

    event DeployProject(address indexed sender, address indexed projectAddress, uint256 timestamp);
}