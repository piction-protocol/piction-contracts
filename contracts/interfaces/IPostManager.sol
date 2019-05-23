pragma solidity ^0.4.24;

interface IPostManager {
    function getPostWriter(string postHash) external view returns(address writer);
    function getPostRawData(string postHash) external view returns(string rawData);
    function getProjectHash(string postHash) external view returns(string projectHash);
}