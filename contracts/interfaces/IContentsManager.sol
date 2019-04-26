pragma solidity ^0.4.24;

interface IContentsManager {
    function getWriter(string contentsHash) external view returns(address writer);
    function getContentsRawData(string contentsHash) external view returns(string rawData);
    function getUserHash(string contentsHash) external view returns(string userHash);
}