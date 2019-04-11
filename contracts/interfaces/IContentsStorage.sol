pragma solidity ^0.4.24;

contract IContentsStorage {
    function setContent(address writer, string contentHash, string rawData, string tag) public;
    function isDuplicatedContent(address writer, string contentHash) public view returns (bool duplicated);
    function setPost(string contentHash, string postHash, string rawData, string tag) public;
    function isDuplicatedPost(string contentHash, string postHash) public view returns (bool duplicated);
}