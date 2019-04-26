pragma solidity ^0.4.24;

interface IPostManager {
    function getPostWriter(string postHash) external view returns(address writer);
    function getPostRawData(string postHash) external view returns(string rawData);
    function getContentsHash(string postHash) external view returns(string contentsHash);

    function updateAddress() external;
    event UpdateAddress(address beforeAddr, address afterAddr);
}