pragma solidity ^0.4.24;

interface IProjectManager {
    function uriValidation(string uri) external view returns(bool);
    function getProjectOwner(string hash) external view returns(address);
    function getProject(string hash) external view returns(bool, address, string);
}