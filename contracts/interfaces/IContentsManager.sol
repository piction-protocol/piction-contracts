pragma solidity ^0.4.24;

interface IContentsManager {
    function createContents(string userHash, string contentsHash, string rawData) external;
    function updateContents(string userHash, string contentsHash, string rawData) external;
    function removeContents(string userHash, string contentsHash) external;
    
    function getWriter(string contentsHash) external returns(address writer);
    function getContentsRawData(string contentsHash) external returns(string rawData);

    event CreateContents(address indexed sender, string userHash, string contentsHash);
    event UpdateContents(address indexed sender, string userHash, string contentsHash);
    event RemoveContents(address indexed sender, string userHash, string contentsHash);
}