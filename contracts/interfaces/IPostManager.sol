pragma solidity ^0.4.24;

interface IPostManager {
    function createPost(string userHash, string contentsHash, string postHash, string rawData) external;
    function updatePost(string userHash, string contentsHash, string postHash, string rawData) external;
    function removePost(string userHash, string contentsHash) external;
    
    function getPostWriter(string contentsHash) external view returns(address writer);
    function getPostRawData(string contentsHash) external view returns(string rawData);
    function getContentsHash(string postHash) external view returns(string contentsHash);
}