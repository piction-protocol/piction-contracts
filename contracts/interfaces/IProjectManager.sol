pragma solidity ^0.4.24;

interface IProjectManager {
    function getWriter(string projectHash) external view returns(address writer);
    function getProjectRawData(string projectHash) external view returns(string rawData);
    function getUserHash(string projectHash) external view returns(string userHash);
}