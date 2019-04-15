pragma solidity ^0.4.24;

interface IPostManager {
    function createPost(string userHash, string contentsHash, string postHash, string rawData) external;
    function updatePost(string userHash, string contentsHash, string postHash, string rawData) external;
    function removePost(string userHash, string contentsHash) external;
    
    function getPostWriter(string contentsHash) external view returns(address writer);
    function getPostRawData(string contentsHash) external view returns(string rawData);

    event CreatePost(address indexed sender, string userHash, string contentsHash, string postHash);
    event UpdatePost(address indexed sender, string userHash, string contentsHash, string postHash);
    event RemovePost(address indexed sender, string userHash, string contentsHash, string postHash);
}