pragma solidity ^0.4.24;

interface IProjectManager {
    function getWriter(string projectHash) external view returns(address writer);
    function getProjectRawData(string projectHash) external view returns(string rawData);
    function getUserHash(string projectHash) external view returns(string userHash);
    function subscription(string cdName, address user, uint256 amount, bytes data) external;
    function isSubscribing(string subscriptionHash) external view returns(bool);
}