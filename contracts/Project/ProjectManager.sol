pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "./Project.sol";

contract ProjectManager is ValidValue {

    mapping(string => bool) private urlChecker;

    /**
     * @dev 프로젝트 생성 
     * @param url 프로젝트 고유한 url 정보
     * @param title 프로젝트 이름
     * @param subscriptionPrice 프로젝트 구독 가격
     */
    function createProject(
        string url, 
        string title, 
        uint256 subscriptionPrice
    ) 
        external
        validString(url) 
        validString(title)
    {
        require(!urlChecker[url], "ProjectManager createProject 0");

        address project = new Project(url, title, subscriptionPrice, msg.sender);

        emit DeployProject(msg.sender, project, now * 1000);
    }

    /**
     * @dev 프로젝트 url 중복 확인
     * @param url 프로젝트 고유한 url 정보
     * @return url 중복 여부
     */
    function isExistedUrl(string url) external view returns(bool) {
        return urlChecker[url];
    }

    event DeployProject(address indexed sender, address indexed projectAddress, uint256 timestamp);
}