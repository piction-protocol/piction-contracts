pragma solidity ^0.4.24;

interface IContentsManager {
    function createContent(string userHash, string contentHash, string rawData) external;
    
    function getWriter(string contentHash) external returns(address writer);
}