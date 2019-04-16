pragma solidity ^0.4.24;

interface IContentsManager {
    function createContents(string userHash, string contentsHash, string rawData) external;
    function updateContents(string userHash, string contentsHash, string rawData) external;
    function deleteContents(string userHash, string contentsHash) external;
    
    function getWriter(string contentsHash) external view returns(address writer);
    function getContentsRawData(string contentsHash) external view returns(string rawData);
    function getUserHash(string contentsHash) external view returns(string contentsHash);
}